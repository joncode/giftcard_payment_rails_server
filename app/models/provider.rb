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
#

class Provider < ActiveRecord::Base
  attr_accessible :address, :city, :description, :logo, :name, :state, :user_id, :zip, :zinger, :phone, :email, :twitter, :facebook, :website 
                                                                                                  
  belongs_to :user                                                                              
  has_one    :menu                                                                              
  has_many   :orders                                                                            
  has_one    :menu_string
  has_many   :gifts
  
  def full_address
    "#{self.address},  #{self.city}, #{self.state}"
  end
end
