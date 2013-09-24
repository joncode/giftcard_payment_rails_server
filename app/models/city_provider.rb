class CityProvider < ActiveRecord::Base
  attr_accessible :city, :providers_array


  validates_presence_of :providers_array, :city
end
