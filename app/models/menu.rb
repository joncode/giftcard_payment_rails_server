class Menu < ActiveRecord::Base
  attr_accessible :item_id, :position, :price, :provider_id
end
