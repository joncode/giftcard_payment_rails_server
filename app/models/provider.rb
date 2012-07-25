class Provider < ActiveRecord::Base
  attr_accessible :address, :city, :description, :logo, :name, :state, :user_id, :zip
  
  belongs_to :user
  has_many   :menus 
  has_many   :orders
  has_many   :menu_strings
  has_many   :gifts
end
