# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  email           :string(255)     not null
#  admin           :boolean         default(FALSE)
#  photo           :string(255)
#  password_digest :string(255)     not null
#  remember_token  :string(255)     not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  address         :string(255)
#  address_2       :string(255)
#  city            :string(20)
#  state           :string(2)
#  zip             :string(16)
#  credit_number   :string(255)
#  phone           :string(255)
#  first_name      :string(255)
#  last_name       :string(255)
#  provider_id     :string(255)
#  facebook_id     :string(255)
#  handle          :string(255)
#

class User < ActiveRecord::Base

  attr_accessible  :email, :password, :password_confirmation, :photo, :photo_cache, :first_name, :last_name, :phone, :address, :address_2, :city, :state, :zip, :credit_number, :admin, :facebook_id, :facebook_access_token, :facebook_expiry, :foursquare_id, :foursquare_access_token, :provider_id, :handle, :server_code
  mount_uploader    :photo, ImageUploader
  
  
  has_many :employees
  has_many :providers, :through => :employees
  has_many :gifts
  has_many :givers, through: :connections, source: "giver"
  has_many :connections, foreign_key: "receiver_id", dependent: :destroy
  has_many :reverse_connections, foreign_key: "giver_id",
                                  class_name: "Connection",
                                  dependent: :destroy
  has_many :receivers, through: :reverse_connections, source: :receiver
  
  
  has_many :microposts, dependent: :destroy
  has_many :followed_users, through: :relationships, source: "followed"
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_relationships, foreign_key: "followed_id",
                                  class_name: "Relationship",
                                  dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  has_secure_password

  
  #  User.next(user) & previous functions for rails console
  self.class_eval do
    scope :previous,  lambda { |i| {:conditions => ["#{self.table_name}.id < ?", i], :order => "#{self.table_name}.id DESC", :limit => 1 }}
    scope :next,      lambda { |i| {:conditions => ["#{self.table_name}.id > ?", i], :order => "#{self.table_name}.id ASC",  :limit => 1 }}
  end
  
  
  # save data to db with proper cases
  before_save { |user| user.email      = email.downcase  }
  before_save { |user| user.first_name = first_name.capitalize if first_name}
  before_save { |user| user.last_name  = last_name.capitalize if last_name }
  before_save   :extract_phone_digits    # remove all non-digits from phone
  
  before_create :create_remember_token  # creates unique remember token for user
  after_update :crop_photo
  
  # before_save   :validate_server_code   # validation does not return error
  # validates_presence_of :city, :state, :zip, :address, :credit_number
  validates :first_name  , presence: true, length: { maximum: 50 }
  validates :last_name  , presence: true, length: { maximum: 50 }
  # validates :phone , presence: true, format: { with: VALID_PHONE_REGEX }, uniqueness: true
  validates :email , presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :server_code, length: {is: 4}, numericality: { only_integer: true }, :if => :check_for_server_code
  
  def feed
    Micropost.from_users_followed_by(self)
  end
  
  def username
    "#{self.first_name} #{self.last_name}"
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
  
  def checkin_to_foursquare(fsq_id, lat, lng)
    requrl = "https://foursquare.com/oauth2/access_token"
    response = HTTParty.post(url, :query => {:venueId => fsq_id, :ll => ["?,?",lat,lng], :oauth_token => self.foursquare_access_token})
    return false if response.code != 200
    return true
  end
  
  private
    
    def crop_photo
      photo.recreate_versions! if crop_x.present?
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

    def check_for_server_code
      self.server_code != nil
    end
    
    def validate_server_code
    # before update if the update is to the server code
    # get the providers that the user works for 
    # save server code in provider server code array - remove the old server code 
    # or should this be done thru model associations
    # where you ask provider.staff.server_codes and get all the server codes associated with that provider
      flag = true
      if self.server_code != nil
        flag = self.server_code.length == 4 ? true : false
      end
      return flag
    end
end
