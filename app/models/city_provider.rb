class CityProvider < ActiveRecord::Base
  attr_accessible :city, :providers_array


  validates_presence_of :providers_array, :city
  validates_uniqueness_of :city, case_sensitive: false
end
# == Schema Information
#
# Table name: city_providers
#
#  id              :integer         not null, primary key
#  city            :string(255)
#  providers_array :text
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

