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
  attr_accessible  :email, :password, :password_confirmation, :photo, :first_name, :last_name, :phone, :address, :address_2, :city, :state, :zip, :credit_number, :admin, :facebook_id, :provider_id, :handle, :server_code
  
  serialize :provider_id, Array
  
  has_many :providers
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
  
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  
  validates_presence_of :city, :state, :zip, :address, :credit_number
  validates :first_name  , presence: true, length: { maximum: 50 }
  validates :last_name  , presence: true, length: { maximum: 50 }
  validates :phone , presence: true, format: { with: VALID_PHONE_REGEX }, uniqueness: true
  validates :email , presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  
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
  
  private
  
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
  
end
