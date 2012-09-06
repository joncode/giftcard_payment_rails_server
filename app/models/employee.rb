class Employee < ActiveRecord::Base
  attr_accessible :active, :clearance, :provider_id, :user_id
  
  belongs_to :user
  belongs_to :provider
end
