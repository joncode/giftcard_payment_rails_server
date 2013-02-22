class User < ActiveRecord::Base

  attr_accessible  :email, :password, :password_confirmation, 
  :photo, :photo_cache, :first_name, :last_name, :phone, 
  :address, :address_2, :city, :state, :zip, :credit_number, 
  :admin, :facebook_id, :facebook_access_token, :facebook_expiry, 
  :foursquare_id, :foursquare_access_token, :provider_id, :handle, 
  :server_code, :sex, :birthday, :is_public,
  :iphone_photo, :fb_photo, :use_photo, :secure_image, :origin, :twitter

  # can't mass assign these attributes
  # active, created_at, facebook_auth_checkin, id, password_digest, persona, remember_token, reset_token, reset_token_sent_at, updated_at

  attr_accessible :crop_x, :crop_y, :crop_w, :crop_h 
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  mount_uploader   :photo, UserAvatarUploader
  mount_uploader   :secure_image, UserAvatarUploader

  has_many :employees
  has_many :providers, :through => :employees
  has_many :orders,    :through => :providers
  has_many :gifts,     foreign_key: "giver_id"
  has_many :sales
  has_many :cards
  has_many :locations
  has_many :answers
  has_many :questions, :through => :answers
  has_many :relays , foreign_key: "receiver_id"

  
  # has_many :givers, through: :connections, source: "giver"
  # has_many :connections,          foreign_key: "receiver_id", dependent: :destroy
  # has_many :reverse_connections,  foreign_key: "giver_id",
  #                                class_name: "Connection",
  #                                dependent: :destroy
  # has_many :receivers, through: :reverse_connections, source: :receiver
  # has_many :microposts, dependent: :destroy
  has_many :followed_users, through: :relationships, source: "followed"
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_relationships, foreign_key: "followed_id",
                                  class_name: "Relationship",
                                  dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  has_secure_password
  
  # save data to db with proper cases
  before_save { |user| user.email      = email.downcase  }
  before_save { |user| user.first_name = first_name.capitalize if first_name}
  before_save { |user| user.last_name  = last_name.capitalize  if last_name }
  before_save   :extract_phone_digits       # remove all non-digits from phone
  before_create :create_remember_token      # creates unique remember token for user

      # searches gift db for ghost gifts that belong to new user 
      # after_create for new accounts
      # after_update , :if => :added_social_media TODO
      # this after_save covers both those situations , but also runs the code unnecessarily
  after_save    :collect_incomplete_gifts   

  # after_update  :crop_photo
  
  validates :first_name  , presence: true, length: { maximum: 50 }
  validates :last_name  ,  length: { maximum: 50 }, :unless => :social_media
  validates :phone , format: { with: VALID_PHONE_REGEX }, uniqueness: true, :if => :phone_exists?
  validates :email , format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 },      on: :create, :unless => :social_media
  validates :password_confirmation, presence: true, on: :create, :unless => :social_media
  validates :facebook_id, uniqueness: true, :if => :facebook_id_exists?
  validates :twitter, uniqueness: true, :if => :twitter_exists?
  #/---------------------------------------------------------------------------------------------/
  
  def gifts
    anon_gifts    = Gift.where(anon_id: self.id)
    normal_gifts  = super
    return anon_gifts + normal_gifts
  end

  def social_media
    return true if self.origin == 'f' 
    return true if self.origin == 't'
    return false
  end

  def get_credit_card(card_id)
    self.cards.select { |c| c.id == card_id}
  end

  def display_cards
    self.cards.select do |c| 
      c.nickname
      c.id
      c.last_four
    end
  end

      # custom setters and getters for formatting date to human looking date
  def birthday= birthday
    if birthday.kind_of? String
      bday = Date.strptime(birthday, "%m/%d/%Y")
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

  def bill
    total = self.gifts.sum { |gift| gift.total.to_d }
    total > 0 ? total.to_digits : "0"
  end

  def received
    Gift.where(receiver_id: self.id)
  end

  def all_gifts
    Gift.where("giver_id = :user OR receiver_id = :user OR anon_id = :user", :user => self.id ).order("created_at DESC")
  end

  def feed
    Micropost.from_users_followed_by(self)
  end
  
  def username
    if self.last_name.blank?
      "#{self.first_name}"
    else
      "#{self.first_name} #{self.last_name}"
    end
  end

  def fullname
    self.username
  end

  def get_image(flag)
    puts flag
    if flag == 'secure_image'
      self.get_secure_image
    else
      self.get_photo
    end
  end

  def get_photo
    case self.use_photo
    when "cw"
      self.photo.url
    when "ios"
      self.iphone_photo
    when "fb"
      self.fb_photo
    else 
      if self.photo.blank?
        nil # "#{CLOUDINARY_IMAGE_URL}/v1349221640/yzjd1hk2ljaycqknvtyg.png"
      else
        self.photo.url
      end
    end
  end

  def get_secure_image
    if self.secure_image.blank?
      nil # "#{CLOUDINARY_IMAGE_URL}/v1349221640/yzjd1hk2ljaycqknvtyg.png"
    else
      self.secure_image.url
    end
  end
  
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end
  
  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
  
  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end
  
  def full_address
    "#{self.address},  #{self.city}, #{self.state}"
  end
  
  def update_reset_token
    self.reset_token_sent_at = Time.now
    self.reset_token = SecureRandom.hex(16)
    self.save
  end
  
  def reset_password(password)
    self.password = password
    self.password_confirmation = password
    self.reset_token = nil
    self.reset_token_sent_at = nil
    self.save
  end
  
  def checkin_to_foursquare(fsq_id, lat, lng)
    requrl = "https://foursquare.com/oauth2/access_token"
    response = HTTParty.post(url, :query => {:venueId => fsq_id, :ll => ["?,?",lat,lng], :oauth_token => self.foursquare_access_token})
    return false if response.code != 200
    return true
  end

  def one_provider_to_iphone
    provider = self.providers.dup.pop
    provider.table_photo_hash
  end

  def providers_to_iphone
      # find out how many merchants the user is connected to 
    merchants = self.providers.dup
    response = []
    merchants.each do |m|
      response << m.table_photo_hash
    end
    return response
  end

  def sd_serialize
    "#{self.phone}#{PIPE}#{self.remember_token}#{PIPE}#{self.first_name}#{PIPE}#{PIPE}#{self.last_name}#{PIPE}#{self.birthday}#{PIPE}#{self.phone}#{PIPE}#{self.email}#{PIPE}#{PIPE}#{PIPE}#{self.remember_token}"
  end
  
  private
    
    def collect_incomplete_gifts
              # check Gift.rb for ghost gifts connected to newly created user 
      gifts = []
      if self.facebook_id
        g = Gift.where("status = :stat AND facebook_id = :fb_id",    :stat => 'incomplete', :fb_id   => self.facebook_id)
        gifts.concat g
      end
      if self.foursquare_id
        g = Gift.where("status = :stat AND foursquare_id = :fsq_id", :stat => 'incomplete', :fsq_id  => self.foursquare_id)
        gifts.concat g      
      end 
      if self.twitter
        g = Gift.where("status = :stat AND twitter = :tw", :stat => 'incomplete', :tw  => self.twitter)
        gifts.concat g      
      end
      if self.email
        g = Gift.where("status = :stat AND receiver_email = :em", :stat => 'incomplete', :em  => self.email)
        gifts.concat g      
      end
      if self.phone
        g = Gift.where("status = :stat AND receiver_phone = :phone", :stat => 'incomplete', :phone   => self.phone)
        gifts.concat g     
      end
     
              # update incomplete gifts to open gifts with receiver info
      if gifts.count > 0
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
          else
            error   += 1
          end
        end
                # build success & error messages for reference
        if  error  == 0
          response = "#{success} incomplete gift(s) updated SUCCESSfully on create of #{self.username} #{self.id}"
        else
          response = "#{error} ERRORS updating ghost gifts for #{self.username} #{self.id}"
        end       
                
      else
                # no incomplete gifts found
        response   = "ZERO incomplete ghost gifts for  #{self.username} #{self.id}"
      end
        
                # log the messages output for the method
      puts "COLLECT INCOMPLETE GIFTS"
      puts response
    end

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
    
    def extract_phone_digits
      if self.phone
        phone_raw   = self.phone
        phone_match = phone_raw.match(VALID_PHONE_REGEX)
        self.phone  = phone_match[1] + phone_match[2] + phone_match[3]
      end
    end

    def phone_exists?
      self.phone != nil
    end

    def facebook_id_exists?
      self.facebook_id != nil
    end

    def twitter_exists?
      self.twitter != nil
    end

    def check_for_server_code
      self.server_code != nil
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
#

