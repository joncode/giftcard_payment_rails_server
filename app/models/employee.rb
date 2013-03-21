class Employee < ActiveRecord::Base
  attr_accessible :active, :clearance, :provider_id, :user_id, :retail
  
  belongs_to :user
  belongs_to :provider
  has_many 	 :orders
  belongs_to :brand
  
  validates_presence_of :user_id, :provider_id

  #clearance = "super", "staff"

  def self.create_employee(user, provider)
      # this takes IDs or OBJECTs
    Employee.create(user_id: user, provider_id: provider)
  end

  def server_code
  	self.user.server_code 	
  end

  def name
  	self.user.username
  end

  def secure_image
    self.user.get_secure_image
  end

  def photo
  	self.user.get_photo
  end

  def servers_hash
    send_fields = [ :id, :first_name, :last_name, :photo, :server_code]
    self.users.map { |e| e.serializable_hash only: send_fields  }
  end

  def server_info_to_iphone
    server                  = {}
    server["full_name"]     = self.name
    server["photo"]         = self.photo
    server["secure_image"]  = self.secure_image
    return server
  end
end
# == Schema Information
#
# Table name: employees
#
#  id          :integer         not null, primary key
#  provider_id :integer         not null
#  user_id     :integer         not null
#  clearance   :string(255)     default("staff")
#  active      :boolean         default(TRUE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  brand_id    :integer
#  retail      :boolean         default(TRUE)
#

