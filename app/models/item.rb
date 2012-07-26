class Item < ActiveRecord::Base
  attr_accessible :category, :detail, :item_name, :proof, :type_of, :description 
                                                
  has_many  :gifts
  # has_and_belongs_to_many  :menus
end
