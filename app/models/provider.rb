# == Schema Information
#
# Table name: providers
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  zinger      :string(255)
#  description :text
#  address     :string(255)
#  address_2   :string(255)
#  city        :string(32)
#  state       :string(2)
#  zip         :string(16)
#  user_id     :integer         not null
#  logo        :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  phone       :string(255)
#  email       :string(255)
#  twitter     :string(255)
#  facebook    :string(255)
#  website     :string(255)
#  photo       :string(255)
#  staff_id    :string(255)
#

class Provider < ActiveRecord::Base
  attr_accessible :address, :city, :description, :logo, :name, :state, :user_id, :staff_id, :zip, :zinger, :phone, :email, :twitter, :facebook, :website, :users, :photo, :photo_cache, :logo_cache, :box, :box_cache, :portrait, :portrait_cache, :account_name, :aba, :routing, :bank_account_name, :bank_address, :bank_city, :bank_state, :bank_zip


  has_many   :users, :through => :employees                                                                              
  has_many   :employees
  has_one    :menu                                                                              
  has_many   :orders                                                                            
  has_one    :menu_string
  has_many   :gifts

  mount_uploader :photo,    ImageUploader
  mount_uploader :logo,     ImageUploader
  mount_uploader :box,      ImageUploader
  mount_uploader :portrait, ImageUploader
  

  def self.allWithinBounds(bounds)
    Provider.where(:latitude => (bounds[:botLat]..bounds[:topLat]), :longitude => (bounds[:leftLng]..bounds[:rightLng]))
  end

  def full_address
    "#{self.address},  #{self.city}, #{self.state}"
  end
  
  def get_servers
    # this means get people who are at work not just employed
    # for now without location data, its just employees
    self.users
  end
  
  def server_codes
    self.users.collect {|e| e.server_code}
  end

  def get_server_from_code(code)
    self.users.select {|e| e.server_code == code}
  end
  
  def server_to_iphone
    send_fields = [ :id, :first_name, :last_name, :photo, :server_code]
    users = self.users.map { |g| g.serializable_hash only: send_fields }
  end
end










