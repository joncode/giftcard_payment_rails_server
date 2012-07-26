class MenuString < ActiveRecord::Base
  attr_accessible :full_address, :menu, :menu_id, :provider_id, :version
  
 # belongs_to :menu
  belongs_to :provider
  
end
