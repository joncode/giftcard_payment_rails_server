class Brand < ActiveRecord::Base
	attr_accessible :address, :city, :description, 
	:logo_url, :name, :phone, :state, :user_id, :website

	has_and_belongs_to_many :providers
	has_many :employees
end
