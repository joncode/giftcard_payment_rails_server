# == Schema Information
#
# Table name: brands
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  address     :string(255)
#  city        :string(255)
#  state       :string(255)
#  phone       :string(255)
#  website     :string(255)
#  logo        :string(255)
#  banner      :string(255)
#  portrait    :string(255)
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Brand < ActiveRecord::Base
	attr_accessible :address, :city, :description, 
	:logo, :name, :phone, :state, :user_id, :website

	has_and_belongs_to_many :providers
	has_many :employees
end
