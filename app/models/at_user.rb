class AtUser < ActiveRecord::Base
  include Utility
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
    :recoverable, :rememberable, :trackable, :validatable
  has_many :payments
  has_many :at_users_socials

  before_create :create_remember_token  # creates unique remember token for user

  def name
    if self.last_name.blank?
      "#{self.first_name}"
    else
      "#{self.first_name} #{self.last_name}"
    end
  end

  def giver
    AdminGiver.find(self.id)
  end

  def get_photo
    if self.photo
      self.photo
    else
      nil
    end
  end

  private

  def create_remember_token
    self.remember_token = create_token
  end
end
# == Schema Information
#
# Table name: at_users
#
#  id                  :integer         not null, primary key
#  first_name          :string(255)
#  last_name           :string(255)
#  email               :string(255)
#  phone               :string(255)
#  sex                 :string(255)
#  birthday            :date
#  password_digest     :string(255)
#  remember_token      :string(255)     not null
#  admin               :boolean         default(FALSE)
#  code                :string(255)
#  confirm             :integer         default(0)
#  reset_token_sent_at :datetime
#  reset_token         :string(255)
#  active              :boolean         default(TRUE)
#  db_user_id          :integer
#  address             :string(255)
#  city                :string(255)
#  state               :string(2)
#  zip                 :string(16)
#  photo               :string(255)
#  min_photo           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  last_login          :datetime
#  time_zone           :integer         default(0)
#  acct                :boolean         default(FALSE)
#

