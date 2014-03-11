class User < ActiveRecord::Base
	include UserSerializers
	include Formatter
	include Email
	include Utility

	has_one  :setting
	has_many :pn_tokens
	has_many :brands
	has_many :orders,    :through => :providers
	has_many :oauths

	has_many :sales
	has_many :cards
	has_many :answers
	has_many :questions, :through => :answers
	has_many :user_socials, 	dependent: :destroy
    has_many :sent,       as: :giver,  class_name: Gift
    has_many :received,   foreign_key: :receiver_id, class_name: Gift

    has_many :friends, through: :connections, source: :contact
    has_many :connections, foreign_key: "friend_id", dependent: :destroy

	has_many :followed_users, through: :relationships, source: "followed"
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :reverse_relationships, foreign_key: "followed_id",
	                              class_name: "Relationship",
	                              dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower

	has_secure_password

    validates_with UserSocialValidator
    validates_with UserFirstNameValidator
	validates :first_name, 	presence: true, length: {  maximum: 50 }
	validates :last_name, 	length: { maximum: 50 }, 	:unless => :social_media
	validates :phone , 		format: { with: VALID_PHONE_REGEX }, uniqueness: true, :if => :phone_exists?
	validates :email , 		format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }, :unless => :is_perm_deactive?
	validates :password, 	length: { minimum: 6 },     on: :create
	validates :password_confirmation, presence: true, 	on: :create
	validates :facebook_id, uniqueness: true, 			:if => :facebook_id_exists?
	validates :twitter,     uniqueness: true, 		    :if => :twitter_exists?


	before_save { |user| user.email      = email.downcase unless is_perm_deactive? }
	before_save { |user| user.first_name = first_name.capitalize if first_name }
	before_save { |user| user.last_name  = NameCase(last_name)   if last_name  }
	before_save   :extract_phone_digits       # remove all non-digits from phone
	before_create :create_remember_token      # creates unique remember token for user

	after_save    :collect_incomplete_gifts
	after_save    :persist_social_data, :unless => :is_perm_deactive?
	after_create  :init_confirm_email


	def update args
		args = args.stringify_keys
		us_keys = ["email", "phone", "facebook_id", "twitter"]
		if us_keys.any? { |k| args.has_key? k }
			type_of = "email" if args.has_key? "email"
			type_of = "phone" if args.has_key? "phone"
			type_of = "facebook_id" if args.has_key? "facebook_id"
			type_of = "twitter" if args.has_key? "twitter"
			if args.has_key?("primary")
				self.send("#{type_of}=", args[type_of])
				if self.valid?
					self.save
					unless user_social = UserSocial.create(type_of: type_of.to_s, identifier: args[type_of], user_id: self.id)
						user_social.errors
					end
				else
					self.errors
				end
			else
				self.send("#{type_of}=", args[type_of])
				if self.valid?
					self.reload
					unless user_social = UserSocial.create(type_of: type_of.to_s, identifier: args[type_of], user_id: self.id)
						user_social.errors
					end
				else
					self.errors
				end
			end
		end
		super(args.except!("email", "phone", "facebook_id", "twitter", "primary"))
	end

	def self.app_authenticate(token)
		where(active: true, perm_deactive: false).where(remember_token: token).first
	end

#/---------------------------------------------------------------------------------------------/

	def is_perm_deactive?
		self.perm_deactive == true ? true : false
	end

	def not_suspended?
		self.active && !self.perm_deactive
	end

	def ua_alias
		adj_user_id     = self.id + NUMBER_ID
		"user-#{adj_user_id}"
	end

	def social_media
		return true if self.origin == 'f'
		return true if self.origin == 't'
		return false
	end

	# def friends
	# 	conns = Connection.where(friend_id: self.id)
	# 	binding.pry
	# 	ids   = conns.map { |c| c.contact_id }
	# 	UserSocial.unscoped.where(id: ids)
	# end

####### USER GETTERS AND SETTERS

	def get_credit_card(card_id)
		self.cards.select { |c| c.id == card_id }
	end

			# custom setters and getters for formatting date to human looking date
	def birthday= birthday
		if birthday.kind_of? String
			if !birthday.empty?
				bday = Date.strptime(birthday, "%m/%d/%Y")
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

	def new_socials(user_hsh)
		user_hsh.each do |key, value|
			setter = "#{key}="
			self.send(setter, value)
		end
		self
	end

##################

#######  PHOTO METHODS

	def get_photo
		if self.iphone_photo && self.iphone_photo.length > 14
			self.iphone_photo
		else
			"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"
		end
	end

##################

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

##################

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
    end

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

	def pn_token=(value)
		value 		= PnToken.convert_token(value)
		if pn_token = PnToken.find_by(pn_token: value)
			if pn_token.user_id != self.id
				pn_token.user_id = self.id
				pn_token.save
			end
		else
			PnToken.create!(user_id: self.id, pn_token: value)
		end
	end

	def pn_token
		self.pn_tokens.map {|pnt| pnt.pn_token }
	end

	def facebook_id_exists?
		!self.facebook_id.blank?
	end

	def twitter_exists?
		!self.twitter.blank?
	end

##################

#########   settings methods

	def get_or_create_settings
		if setting = Setting.find_by(user_id: self.id)
			return setting
		else
			return Setting.create(user_id: self.id)
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

	def set_confirm_email
		setting 							= get_or_create_settings
		setting.confirm_email_token 		= create_token
		setting.confirm_email_token_sent_at = Time.now
		setting.save
	end

	def init_confirm_email
		unless Rails.env.development?
			if self.email
				set_confirm_email
				confirm_email
			else
				puts "User created without EMAIL !! #{self.id}"
			end
		end
	end

##################

private

	def persist_social_data

		if email_changed? && (email[-3..-1] != "xxx")
			UserSocial.create(user_id: id, type_of: "email", identifier: email)
		end
		phone_changed? and UserSocial.create(user_id: id, type_of: "phone", identifier: phone)
		facebook_id_changed? and UserSocial.create(user_id: id, type_of: "facebook_id", identifier: facebook_id)
		twitter_changed? and UserSocial.create(user_id: id, type_of: "twitter", identifier: twitter)
	end

	def collect_incomplete_gifts
						# check Gift.rb for ghost gifts connected to newly created user
		gifts = []
		if self.facebook_id
			g = Gift.where("status = :stat AND facebook_id = :fb_id", :stat => 'incomplete', :fb_id   => self.facebook_id.to_s)
			gifts.concat g
		end
		if self.twitter
			g = Gift.where("status = :stat AND twitter = :tw", :stat => 'incomplete', :tw  => self.twitter.to_s)
			gifts.concat g
		end
		if self.email
			g = Gift.where("status = :stat AND receiver_email = :em", :stat => 'incomplete', :em  => self.email)
			gifts.concat g
		end
		if self.phone
			g = Gift.where("status = :stat AND receiver_phone = :phone", :stat => 'incomplete', :phone   => self.phone.to_s)
			gifts.concat g
		end

						# update incomplete gifts to open gifts with receiver info
		response   = if gifts.count > 0
			error   = 0
			success = 0

			gifts.each do |g|
				gift_changes                  = {}
				gift_changes[:status]         = "open"
				gift_changes[:receiver_phone] = self.phone if self.phone
				gift_changes[:receiver_email] = self.email if self.email
				gift_changes[:receiver_id]    = self.id
				gift_changes[:receiver_name]  = self.username

				if g.update_attributes(gift_changes)
					success += 1
					Relay.send_push_incomplete(g) if g.giver_type == "User"
					# email_gift_collected(g)
				else
					error   += 1
				end
			end
							# build success & error messages for reference
			if  error  == 0
				"#{success} incomplete gift(s) updated SUCCESSfully on create of #{self.username} #{self.id}"
			else
				"#{error} ERRORS updating ghost gifts for #{self.username} #{self.id}"
			end

		else
							# no incomplete gifts found
			 "ZERO incomplete ghost gifts for  #{self.username} #{self.id}"
		end

							# log the messages output for the method
		puts response
	end

	def create_remember_token
		self.remember_token = create_token
	end

end
# == Schema Information
#
# Table name: users
#
#  id                      :integer         not null, primary key
#  email                   :string(255)     not null
#  admin                   :boolean         default(FALSE)
	#  photo                   :string(255)
#  password_digest         :string(255)
#  remember_token          :string(255)     not null
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  address                 :string(255)
#  address_2               :string(255)
#  city                    :string(20)
#  state                   :string(2)
#  zip                     :string(16)
#  credit_number           :string(255)
#  phone                   :string(255)
#  first_name              :string(255)
#  last_name               :string(255)
#  facebook_id             :string(255)
#  handle                  :string(255)
#  server_code             :string(255)
#  twitter                 :string(255)
#  active                  :boolean         default(TRUE)
#  persona                 :string(255)     default("")
#  foursquare_id           :string(255)
#  facebook_access_token   :string(255)
#  facebook_expiry         :datetime
#  foursquare_access_token :string(255)
#  sex                     :string(255)
#  is_public               :boolean
#  facebook_auth_checkin   :boolean
	#  iphone_photo            :string(255)
	#  fb_photo                :string(255)
	#  use_photo               :string(255)
	#  secure_image            :string(255)
#  reset_token_sent_at     :datetime
#  reset_token             :string(255)
#  birthday                :date
#  origin                  :string(255)
#  confirm                 :string(255)     default("00")
#

# == Schema Information
#
# Table name: users
#
#  id                      :integer         not null, primary key
#  email                   :string(255)     not null
#  admin                   :boolean         default(FALSE)
#  password_digest         :string(255)     not null
#  remember_token          :string(255)     not null
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  address                 :string(255)
#  address_2               :string(255)
#  city                    :string(20)
#  state                   :string(2)
#  zip                     :string(16)
#  credit_number           :string(255)
#  phone                   :string(255)
#  first_name              :string(255)
#  last_name               :string(255)
#  facebook_id             :string(255)
#  handle                  :string(255)
#  server_code             :string(255)
#  twitter                 :string(255)
#  active                  :boolean         default(TRUE)
#  persona                 :string(255)     default("")
#  foursquare_id           :string(255)
#  facebook_access_token   :string(255)
#  facebook_expiry         :datetime
#  foursquare_access_token :string(255)
#  sex                     :string(255)
#  is_public               :boolean
#  facebook_auth_checkin   :boolean
#  iphone_photo            :string(255)
#  reset_token_sent_at     :datetime
#  reset_token             :string(255)
#  birthday                :date
#  origin                  :string(255)
#  confirm                 :string(255)     default("00")
#  perm_deactive           :boolean         default(FALSE)
#

