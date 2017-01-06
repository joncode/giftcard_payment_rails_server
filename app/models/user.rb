class User < ActiveRecord::Base
	include UserSerializers
	include Formatter
	include Email
	include Utility
	include ShortenPhotoUrlHelper
	include UpdateUserMeta

#   -------------

    auto_strip_attributes :first_name, :last_name, :email, :zip, :city, :address

#   -------------

	has_secure_password

	scope :meta_search, ->(str) {
		where("ftmeta @@ plainto_tsquery(:search)", search: str.downcase)
	}

#	-------------

    validates_with UserSocialValidator
    validates_with UserFirstNameValidator
	validates :first_name, 	presence: true, length: {  maximum: 50 }
	validates :last_name, 	length: { maximum: 50 }, allow_blank: true
	validates :phone , 		format: { with: VALID_PHONE_REGEX }, allow_blank: true
	validates :email , 		format: { with: VALID_EMAIL_REGEX }, unless: :is_perm_deactive?
	validates :password, 	length: { minimum: 6 },     on: :create
	validates :password_confirmation, presence: true,   on: :create
	# validates :facebook_id, uniqueness: true, 			if: :facebook_id_exists?
	# validates :twitter,     uniqueness: true, 		    if: :twitter_exists?

#	-------------

	before_create :create_remember_token      # creates unique remember token for user
	before_save { |user| user.email      = email.downcase unless is_perm_deactive? }
	before_save { |user| user.first_name = first_name.titleize if first_name }
	before_save { |user| user.last_name  = NameCase(last_name) if last_name  }
	before_save   :extract_phone_digits       # remove all non-digits from phone

	after_save    :persist_social_data, :unless => :is_perm_deactive?
	after_save    :make_friends

	after_commit  :init_confirm_email, on: :create
    after_commit  :fire_after_save_queue, on: [:create, :update, :destroy]
	after_commit  :fire_after_create_event, on: :create

#	-------------

	has_one  :setting
    has_one  :affiliation, as: :target
    has_one  :affiliate,   through: :affiliation
	has_many :proto_joins, as: :receivable
	has_many :protos, through: :proto_joins
	has_many :dittos, as: :notable
	has_many :pn_tokens
	has_many :brands
	has_many :orders,    :through => :providers
	has_many :oauths
	has_many :app_contacts
	has_many :sales
	has_many :cards
	has_many :answers
	has_many :questions, :through => :answers
	has_many :user_socials, 	dependent: :destroy
    has_many :sent,       as: :giver,  class_name: Gift

	def received
		Gift.where(receiver_id: self.id).where.not(status: 'schedule')
	end

	has_many :followed_users, through: :relationships, source: :followed
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :reverse_relationships, foreign_key: "followed_id",
	                              class_name: "Relationship",
	                              dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower
	has_many :friendships, dependent: :destroy
	has_many :app_contacts, through: :friendships
	has_many :session_tokens
	has_many :user_points

	belongs_to :client
	belongs_to :partner, polymorphic: true

	attr_accessor :api_v1, :session_token_obj

#	-------------

	def self.search_name(find_text)
		users_scope =  if find_text.blank?
			where(active: true)
		else
            ary = find_text.split(' ')
            if ary.count == 1
                where(active: true).where('first_name ilike ? OR last_name ilike ?',"%#{find_text}%", "%#{find_text}%")
            elsif ary.count == 2
                where(active: true).where('first_name ilike ? AND last_name ilike ?',"%#{ary[0]}%", "%#{ary[1]}%")
            elsif ary.count > 2
	            first_name = ary[0]
                last_name  = ary[1] + ' ' + ary[2]
                where(active: true).where('first_name ilike ? AND last_name ilike ?',"%#{first_name}%", "%#{last_name}%")
            end
		end

        users = users_scope.pluck(:id, :first_name, :last_name, :iphone_photo)
        users.map do |u|
            if u[3].nil?
                { "user_id" => u[0] , "first_name" => u[1] , "last_name" => u[2]  }
            else
                { "user_id" => u[0] , "photo" => u[3] , "first_name" => u[1] , "last_name" => u[2]  }
            end
        end
	end

	def self.app_authenticate(token)
		#where(active: true, perm_deactive: false, remember_token: token).first
		SessionToken.app_authenticate(token)
	end

    def self.index
        []
    end

#	-------------

	def link= link
		lp = LandingPage.where(link: link).first
		unless lp.nil?
			self.affiliate = lp.affiliate
			lp.users += 1
			lp.save
		end
	end

	def remember_token
		if self.session_token_obj.present?
			self.session_token_obj.token
		elsif sst = SessionToken.where(user_id: self.id).order(created_at: :desc).limit(1).first
			self.session_token_obj = sst
			sst.token
		else
			super
		end
	end

#/---------------------------------------------------------------------------------------------/


	def current_oauth(net_name: 'facebook', net_id: nil)
		if net_id.nil?
			self.oauths.where(network: net_name).order(created_at: :desc).first
		else
			self.oauths.where(network: net_name, network_id: net_id).order(created_at: :desc).first
		end
	end

########   USER SOCIAL METHODS



	def new_socials(user_hsh)
			# used by Admt::V2::GiftsController to add receiver info to a gift with the add receiver button
		user_hsh.each do |key, value|
			setter = "#{key}="
			self.send(setter, value)
		end
		self
	end

    def activate_all_socials
    	UserSocial.unscoped.where(user_id: self.id).each do |us|
    		us.update(active: true)
    	end
    end

    def deactivate_all_socials
    	self.user_socials.each do |us|
    		us.user.deactivate_social(us.type_of.to_sym, us.identifier)
    	end
    end

    def deactivate_social type_of, identifier
    	type_of = type_of.to_s
	    user_social            = self.user_socials.where(identifier: identifier).first
	    secondary_user_socials = self.user_socials.where(type_of: type_of).where.not(identifier:identifier)
	    if ["email", "phone", "facebook_id", "twitter"].include?(type_of) && self.send(type_of) == identifier
        	if secondary_user_socials.count > 0
        		user_social.update(active: false)
        		secondary_identifier = secondary_user_socials.first.identifier
        		self.update_column(type_of.to_sym, secondary_identifier)
        	elsif ["phone", "facebook_id", "twitter"].include?(type_of)
        		user_social.update(active: false)
	        	self.send("#{type_of}=", nil)
	        	self.save
			elsif ["email"].include?(type_of) && self.active == false
				user_social.update(active: false)
			else
				puts "cannot deactivate primary email for user that is active"
			end
        else
        	user_social.update(active: false)
        end
        user_social
    end

####### USER GETTERS AND SETTERS

	##########  AFFILIATION DUCKTYPE
		def name_address_hsh
			h            = {}
			h["name"]    = "#{self.first_name} #{self.last_name}"
			h["address"] = self.city
			h
		end

		def create_affiliation(affiliate)
			self.affiliate_url_name = affiliate.url_name
		end
	###########

	def short_image_url
		shorten_photo_url(self.iphone_photo)
	end

	def get_photo
		if self.iphone_photo && self.iphone_photo.length > 14
			self.iphone_photo
		else
			BLANK_AVATAR_URL
		end
	end

	def get_credit_card(card_id)
		self.cards.select { |c| c.id == card_id }
	end

			# custom setters and getters for formatting date to human looking date
	def birthday= birthday
		if birthday.kind_of? String
			if !birthday.empty?
				begin
					bday = Date.strptime(birthday, "%m/%d/%Y")
				rescue
					bday = ""
				end
			else
				bday = birthday
			end
		else
			bday = birthday
		end
		super(bday)
	end

	def birthday
		x = super
		if x.kind_of? Date
			m = x.month
			d = x.day
			y = x.year
			"#{m}/#{d}/#{y}"
		else
			x
		end
	end

	def name
		if self.last_name.blank?
			"#{self.first_name}"
		else
			"#{self.first_name} #{self.last_name}"
		end
	end

	alias_method :username, :name
	alias_method :fullname, :name

#######  GIFT SCOPE METHODS

	def received
		Gift.where(receiver_id: self.id)
	end

	def all_gifts
		Gift.where("giver_id = :user OR receiver_id = :user OR anon_id = :user", :user => self.id ).order("created_at DESC")
	end

	def gifts
		anon_gifts    = Gift.where(anon_id: self.id)
		normal_gifts  = super
		return anon_gifts + normal_gifts
	end

#######  UTILITY  METHODS

    def permanently_deactivate
        self.active        = false
        self.perm_deactive = true
        self.phone         = nil
        self.facebook_id   = nil
        self.twitter       = nil
        self.email         = nil
        save
        self.deactivate_all_socials
    end

    def suspend
    	self.toggle! :active
    	if self.active == false
    		self.deactivate_all_socials
		else
			self.activate_all_socials
		end
    end

	def is_perm_deactive?
		self.perm_deactive
	end

	def not_suspended?
		self.active && !self.perm_deactive
	end

##########   PASSWORD & EMAIL METHODS

	def update_reset_token
		self.reset_token_sent_at = Time.now
		self.reset_token 		 = SecureRandom.hex(16)
		self.save
	end

	def reset_password(password)
		self.password 			   = password
		self.password_confirmation = password
		self.reset_token 		   = nil
		self.reset_token_sent_at   = nil
		self.save
	end

	def set_confirm_email
		settings 							= get_or_create_settings
		settings.confirm_email_token 		= create_token
		settings.confirm_email_token_sent_at = Time.now
		settings.save
	end

	def init_confirm_email
		if thread_on?
			Resque.enqueue(ConfirmEmailJob, self.id, self.email)
		else
			ConfirmEmailJob.perform(self.id, self.email)
		end
	end

##########   PN TOKEN METHODS

	def ua_alias
		"user-#{self.obscured_id}"
	end

	def obscured_id
		self.id + NUMBER_ID
	end

	def pn_token=(value_ary)
		if value_ary.kind_of? Array
			value    = value_ary[0]
			platform = value_ary[1] || 'ios'
		else
			value    = value_ary
			platform = 'ios'
		end
		PnToken.find_or_create_token(self.id, value, platform)
	end

	def pn_token
		self.pn_tokens.map {|pnt| pnt.pn_token }
	end

	def apids
		self.pn_tokens.where(platform: "android").map(&:pn_token)
	end

#########   settings methods

	def get_or_create_settings
		if setting = Setting.find_or_create_by(user_id: self.id)
			return setting
		end
	end

	def get_settings
		settings = get_or_create_settings
		return settings.app_serialize
	end

	def save_settings(data)
		settings = get_or_create_settings
		remove_key_from_hash(data, "user_id")
		if settings.update_attributes(data)
			return true
		end
		return false
	end

	def setting
		get_or_create_settings
		# remove this and make setting creation eager
	end

private

	def make_friends
		#log_bars "'make_friends' after save callback on User model commented out 6/23/14"
		# unless Rails.env.production?
		# 	Resque.enqueue(FriendPushJob, self.id, 1)
		# end
	end

	def persist_social_data
		if email_changed? && (email[-3..-1] != "xxx")
			UserSocial.find_or_create_by(user_id: id, type_of: "email", identifier: email)
		end
		phone_changed? and UserSocial.find_or_create_by(user_id: id, type_of: "phone", identifier: phone)
		facebook_id_changed? and UserSocial.find_or_create_by(user_id: id, type_of: "facebook_id", identifier: facebook_id.to_s)
		twitter_changed? and UserSocial.find_or_create_by(user_id: id, type_of: "twitter", identifier: twitter.to_s)
	end

	def facebook_id_exists?
		!self.facebook_id.blank?
	end

	def twitter_exists?
		!self.twitter.blank?
	end

	def create_remember_token
		self.remember_token = create_token
	end

	def fire_after_save_queue
        Resque.enqueue(UserAfterSaveJob, self.id)
	end

	def fire_after_create_event
		Resque.enqueue(UserAfterCreateEvent, self.id)
	end

end

# == Schema Information
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  email               :string(255)
#  password_digest     :string(255)     not null
#  remember_token      :string(255)     not null
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  address             :string(255)
#  address_2           :string(255)
#  city                :string(20)
#  state               :string(2)
#  zip                 :string(16)
#  phone               :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  facebook_id         :string(255)
#  handle              :string(255)
#  twitter             :string(255)
#  active              :boolean         default(TRUE)
#  persona             :string(255)     default("")
#  sex                 :string(255)
#  is_public           :boolean
#  iphone_photo        :string(255)
#  reset_token_sent_at :datetime
#  reset_token         :string(255)
#  birthday            :date
#  origin              :string(255)
#  confirm             :string(255)     default("00")
#  perm_deactive       :boolean         default(FALSE)
#  cim_profile         :string(255)
#  ftmeta              :tsvector
#  affiliate_url_name  :string(255)
#

