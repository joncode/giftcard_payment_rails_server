# == Schema Information
#
# Table name: providers
#
#  id                :integer         not null, primary key
#  name              :string(255)     not null
#  zinger            :string(255)
#  description       :text
#  address           :string(255)
#  address_2         :string(255)
#  city              :string(32)
#  state             :string(2)
#  zip               :string(16)
#  logo              :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  phone             :string(255)
#  email             :string(255)
#  twitter           :string(255)
#  facebook          :string(255)
#  website           :string(255)
#  photo             :string(255)
#  sales_tax         :string(255)
#  active            :boolean         default(TRUE)
#  account_name      :string(255)
#  aba               :string(255)
#  routing           :string(255)
#  bank_account_name :string(255)
#  bank_address      :string(255)
#  bank_city         :string(255)
#  bank_state        :string(255)
#  bank_zip          :string(255)
#  portrait          :string(255)
#  box               :string(255)
#  latitude          :float
#  longitude         :float
#  foursquare_id     :string(255)
#

class Provider < ActiveRecord::Base
  attr_accessible :address, :city, :description, :logo, :name, :state, :user_id, :staff_id, :zip, :zinger, :phone, :email, :twitter, :facebook, :website, :users, :photo, :photo_cache, :logo_cache, :box, :box_cache, :portrait, :portrait_cache, :account_name, :aba, :routing, :bank_account_name, :bank_address, :bank_city, :bank_state, :bank_zip


  has_many   :users, :through => :employees                                                                              
  has_many   :employees
  has_one    :menu                                                                              
  has_many   :orders                                                                            
  has_one    :menu_string
  has_many   :gifts
  has_many   :servers, class_name: "Employee"

  mount_uploader :photo,    ImageUploader
  mount_uploader :logo,     ImageUploader
  mount_uploader :box,      ImageUploader
  mount_uploader :portrait, ImageUploader
  

  def self.allWithinBounds(bounds)
    puts bounds
    Provider.where(:latitude => (bounds[:botLat]..bounds[:topLat]), :longitude => (bounds[:leftLng]..bounds[:rightLng]))
  end

  def full_address
    "#{self.address},  #{self.city}, #{self.state}"
  end

  def complete_address
    "#{self.address}\n#{self.city}, #{self.state} #{self.zip}"
  end
  
  def get_photo
    if self.box.blank?
      "#{CLOUDINARY_IMAGE_URL}/v1349150293/upqygknnlerbevz4jpnw.png"
    else
      self.box.url
    end
  end

  def get_image(flag)
    case flag
    when "logo"
      photo = self.logo.url
    when "portrait"
      photo = self.portrait.url
    when "landscape"
      photo = self.photo.url
    else
      photo = self.box.url 
    end 
    if photo.blank?
      photo = "#{CLOUDINARY_IMAGE_URL}/v1349150293/upqygknnlerbevz4jpnw.png"
    end
    return photo
  end

  def get_servers
    # this means get people who are at work not just employed
    # for now without location data, its just employees
    self.employees
  end
  
  def server_codes
    self.employees.collect {|e| e.server_code}
  end

  def get_server_from_code(code)
    self.employees.select {|e| e.server_code == code}
  end
   
  def get_server_from_code_to_iphone(code)
    server_in_array = self.employees.select {|e| e.server_code == code}
    server = server_in_array.pop
    server.server_info_to_iphone if server
  end

  def server_to_iphone
    if self.employees.count != 0
      send_fields = [:first_name, :last_name, :server_code]
      self.users.map { |e| e.serializable_hash only: send_fields  }
    else
      "no servers set up yet"
    end
  end

  def table_photo_hash
        # return the merchant name
        # return the table view photo url
        # call the table view photo at 320px x 50px off cloudinary
    response = {}
    response["provider_name"]   = self.name
    response["table_photo_url"] = self.photo.url
    response["provider_id"]     = self.id.to_s 
    return response   
  end 

end
 







