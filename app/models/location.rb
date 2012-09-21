class Location < ActiveRecord::Base
  attr_accessible :foursquare_id, :foursquare_venue_id, :latitude, :longitude, :provider_id, :user_id
end
