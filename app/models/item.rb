class Item < ActiveRecord::Base
  attr_accessible :category, :detail, :item_name
  
  has_many  :gifts
end
