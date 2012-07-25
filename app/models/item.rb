class Item < ActiveRecord::Base
  attr_accessible :category, :detail, :item_name
  
  has_many  :gifts
  has_and_belongs_to_many  :menus
end
