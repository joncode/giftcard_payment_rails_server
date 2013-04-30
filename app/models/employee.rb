class Employee < ActiveRecord::Base
  attr_accessible :active, :clearance, :provider_id, :user_id, :retail
  CLEARANCE       = ['admin', 'full', 'manager', 'staff']

  belongs_to :user
  belongs_to :provider
  has_many 	 :orders
  belongs_to :brand
  
  validates_presence_of :provider_id

  #clearance = "super", "staff"

  def self.create_employee(user, provider)
      # this takes IDs or OBJECTs
    Employee.create(user_id: user, provider_id: provider)
  end

  def self.users_not_staff(provider, user)
    Employee.where("provider_id = :merchant AND user_id != :user", :merchant => provider.id , :user => user.id).order("created_at DESC").page(params[:page]).per_page(8)
  end

  # def self.where(params={}, *args)
  #     if params.kind_of?(Hash) && !params.has_key?(:active) && !params.has_key?("active")
  #       params[:active] = true
  #       super(params, *args)
  #     elsif params.kind_of?(String)
  #       super(params, *args).where(active: true)
  #     else
  #       super(params, *args)
  #     end
  # end

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

