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

class Location < ActiveRecord::Base
  attr_accessible :foursquare_venue_id, :latitude, :longitude, :provider_id, :user_id, :checkin_id, :zip, :state, :city, :street, :name, :country, :vendor_type, :vendor_id
  belongs_to :user
  
  def self.allUsersWithinBounds(userIds,bounds)
    Location.find(:all,{ 
      :joins => :user,
      :order => "locations.created_at",
      :conditions => ["locations.latitude >= ? AND locations.latitude <= ? AND locations.longitude >= ? AND locations.longitude <= ? AND locations.user_id IN (?)",bounds[:botLat],bounds[:topLat],bounds[:leftLng],bounds[:rightLng],userIds]
    })
  end
end
