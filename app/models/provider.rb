class Provider < ActiveRecord::Base
  attr_accessible :address, :city, :description, :logo, :name, :state, :user_id, :zip, :zinger, :phone, :email, :twitter, :facebook, :website 
                                                                                                  
  belongs_to :user                                                                              
  has_one    :menu                                                                              
  has_many   :orders                                                                            
  has_one    :menu_string
  has_many   :gifts
end
