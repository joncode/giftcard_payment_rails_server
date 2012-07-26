class Menu < ActiveRecord::Base
  attr_accessible :item_id, :position, :price, :provider_id 

  belongs_to   :provider
  # has_and_belongs_to_many   :items
  # has_many     :menu_strings
  
end
