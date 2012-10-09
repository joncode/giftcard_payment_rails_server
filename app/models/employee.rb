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
#

class Employee < ActiveRecord::Base
  attr_accessible :active, :clearance, :provider_id, :user_id
  
  belongs_to :user
  belongs_to :provider
  has_many 	 :orders,    :through => :provider
  
  validates_presence_of :user_id, :provider_id

  def server_code
  	self.user.server_code 	
  end

  def name
  	self.user.username
  end

  def photo
  	self.user.photo
  end

  def servers_hash
    send_fields = [ :id, :first_name, :last_name, :photo, :server_code]
    self.users.map { |e| e.serializable_hash only: send_fields  }
  end

  def server_info_to_iphone
    send_fields = [:first_name, :last_name, :photo, :iphone_photo, :server_code, :use_photo]
    server = self.user.serializable_hash only: send_fields
    if server["use_photo"]    == "cw"
      # remove extra values from cw photo
      photo_for_iphone = server["photo"]["url"]
      server["photo"] = photo_for_iphone
    elsif server["use_photo"] == "ios"
      # remove :photo from server hash
      # rename :iphone_photo to :photo
      server.delete("photo")
      server["photo"] = server["iphone_photo"]
    else
      # same as cw for now, this should also take into account fb photo etc
      photo_for_iphone = server["photo"]["url"]
      server["photo"] = photo_for_iphone      
    end
    # remove iphone_photo as this is moved to photo for iphone_photo
    server.delete("iphone_photo")
    # remove use_photo , it is not needed in app
    server.delete("use_photo")
    return server
  end

  def servers
    # get the employee_id and user_id 
  # from user record
    # get the full_name 
    # photo url
    # server_code

  end

end
