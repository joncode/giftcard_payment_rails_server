class CityProvider < ActiveRecord::Base
  attr_accessible :city, :providers_array
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

