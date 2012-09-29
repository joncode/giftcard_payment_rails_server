class Employee < ActiveRecord::Base
  attr_accessible :active, :clearance, :provider_id, :user_id
  
  belongs_to :user
  belongs_to :provider
  has_many 	 :orders,    :through => :provider
  
  validates_presence_of :user_id, :provider_id

  def server_code
  	self.user.server_code 	
  end

  def name
  	self.user.username
  end

  def photo
  	self.user.photo
  end

end
