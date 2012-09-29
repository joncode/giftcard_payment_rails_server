class Employee < ActiveRecord::Base
  attr_accessible :active, :clearance, :provider_id, :user_id
  
  belongs_to :user
  belongs_to :provider
  has_many 	 :orders,    :through => :provider
  
  validates_presence_of :user_id, :provider_id 

end
