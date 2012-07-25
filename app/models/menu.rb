class Menu < ActiveRecord::Base
  attr_accessible :item_id, :position, :price, :provider_id 

  belongs_to   :providers
  has_many     :menu_strings
  
end
