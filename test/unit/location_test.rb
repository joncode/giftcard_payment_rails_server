# == Schema Information
#
# Table name: locations
#
#  id                  :integer         not null, primary key
#  latitude            :float
#  longitude           :float
#  provider_id         :integer
#  user_id             :integer
#  foursquare_venue_id :string(255)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  vendor_id           :string(255)
#  vendor_type         :string(255)
#  name                :string(255)
#  street              :string(255)
#  city                :string(255)
#  state               :string(255)
#  country             :string(255)
#  zip                 :string(255)
#  checkin_id          :string(255)
#

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
