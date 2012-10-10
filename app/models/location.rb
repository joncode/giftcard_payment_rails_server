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
    #All the UNIQUE users within given bounds.
    Location.find(:all,{ 
      :joins => :user,
      :order => "locations.created_at",
      :conditions => ["locations.latitude >= ? AND locations.latitude <= ? AND locations.longitude >= ? AND locations.longitude <= ? AND locations.user_id IN (?)",bounds[:botLat],bounds[:topLat],bounds[:leftLng],bounds[:rightLng],userIds]
    }).uniq{ |loc| loc[:user_id] }
  end
  
  #Checkin functions. Responsible for maintaining the integrity of the data structure
  #Example:
  #{
  #      "id": "10100484986120722", 
  #      "from": {
  #        "name": "Richard Bozard", 
  #        "id": "112797"
  #      }, 
  #      "place": {
  #        "id": "111348207073", 
  #        "name": "Weezie's Kitchen", 
  #        "location": {
  #          "street": "3123 West Cary Street", 
  #          "city": "Richmond", 
  #          "state": "VA", 
  #          "country": "United States", 
  #          "zip": "23220", 
  #          "latitude": 37.55350160247, 
  #          "longitude": -77.481256996167
  #        }
  #      }, 
  #      "application": {
  #        "name": "Facebook for iPhone", 
  #        "namespace": "fbiphone", 
  #        "id": "6628568379"
  #      }, 
  #      "created_time": "2012-09-28T21:36:13+0000"
  #    },
  def self.createWithFacebookCheckin(checkin,user)
    provider = Provider.find_by_foursquare_id(checkin["place"]["id"])
    
    newLocation = Location.create({
      :provider_id => provider ? provider[:id] : nil, 
      :user_id => user[:id], 
      :created_at => Date.parse(checkin["created_time"]),
      :checkin_id => checkin["id"], 
      :vendor_type => "facebook", 
      :vendor_id => checkin["place"]["id"], 
      :latitude => checkin["place"]["location"]["latitude"], 
      :longitude => checkin["place"]["location"]["longitude"],
      :name => checkin["place"]["name"], 
      :street => checkin["place"]["location"]["street"], 
      :city => checkin["place"]["location"]["city"], 
      :state => checkin["place"]["location"]["state"], 
      :country => checkin["place"]["location"]["country"], 
      :zip => checkin["place"]["location"]["zip"]
    })
    #Handle any broadcasting
    broadcastLocationToFriends(newLocation,user)
  end
  
  #Example:
  #{
  #    "id": "4e6fe1404b90c00032eeac34",
  #    "createdAt": 1315955008,
  #    "type": "checkin",
  #    "timeZone": "America/New_York",
  #    "user": {
  #        "id": "1",
  #        "firstName": "Jimmy",
  #        "lastName": "Foursquare",
  #        "photo": "https://foursquare.com/img/blank_boy.png",
  #        "gender": "male",
  #        "homeCity": "New York, NY",
  #        "relationship": "self"
  #    },
  #    "venue": {
  #        "id": "4ab7e57cf964a5205f7b20e3",
  #        "name": "foursquare HQ",
  #        "contact": {
  #            "twitter": "foursquare"
  #        },
  #        "location": {
  #            "address": "East Village",
  #            "lat": 40.72809214560253,
  #            "lng": -73.99112284183502,
  #            "city": "New York",
  #            "state": "NY",
  #            "postalCode": "10003",
  #            "country": "USA"
  #        },
  #        "categories": [
  #            {
  #                "id": "4bf58dd8d48988d125941735",
  #                "name": "Tech Startup",
  #                "pluralName": "Tech Startups",
  #                "shortName": "Tech Startup",
  #                "icon": "https://foursquare.com/img/categories/building/default.png",
  #                "parents": [
  #                    "Professional & Other Places",
  #                    "Offices"
  #                ],
  #                "primary": true
  #            }
  #        ],
  #        "verified": true,
  #        "stats": {
  #            "checkinsCount": 7313,
  #            "usersCount": 565,
  #            "tipCount": 128
  #        },
  #        "url": "http://foursquare.com"
  #    }
  #}
  def self.createWithFoursquareCheckin(checkin,user)
    provider = Provider.find_by_foursquare_id(checkin["venue"]["id"])
    
    newLocation = Location.create({
      :provider_id => provider ? provider[:id] : nil, 
      :user_id => user[:id], 
      :created_at => DateTime.strptime("#{checkin["createdAt"]}",'%s'),
      :checkin_id => checkin["id"], 
      :vendor_type => "foursquare", 
      :vendor_id => checkin["venue"]["id"], 
      :latitude => checkin["venue"]["location"]["lat"], 
      :longitude => checkin["venue"]["location"]["lng"],
      :name => checkin["venue"]["name"], 
      :street => checkin["venue"]["location"]["address"], 
      :city => checkin["venue"]["location"]["city"], 
      :state => checkin["venue"]["location"]["state"], 
      :country => checkin["venue"]["location"]["country"], 
      :zip => checkin["venue"]["location"]["postalCode"]
    })
    #Handle any broadcasting
    broadcastLocationToFriends(newLocation,user)
    
    #Reply to the foursquare checkin.
    followedUserIds = user.followed_users.map { |u| u.id }
    bounds = {:botLat => newLocation[:latitude]-0.01, :topLat => newLocation[:latitude]+0.01, :leftLng => newLocation[:longitude]-0.01, :rightLng => newLocation[:longitude]+0.01}
    fourHoursAgo = Time.new - 4.hours
    friendsNearbyDrinkboardLocs = Location.find(:all,{ 
      :joins => :user,
      :order => "locations.created_at",
      :conditions => ["locations.latitude >= ? AND locations.latitude <= ? AND locations.longitude >= ? AND locations.longitude <= ? AND locations.user_id IN (?) AND locations.created_at > ? AND locations.provider_id IS NOT NULL AND users.is_public = ?",bounds[:botLat],bounds[:topLat],bounds[:leftLng],bounds[:rightLng],followedUserIds,fourHoursAgo,true]
    })
    
    if friendsNearbyDrinkboardLocs.count > 0
      friendLoc = friendsNearbyDrinkboardLocs[0]
      friendLocUser = friendLoc.user
      fsqMsg = "Your friend #{friendLocUser[:first_name]} #{friendLocUser[:last_name]} is nearby at #{friendLoc[:name]}. Check out Drinkboard to buy them a drink."
      HTTParty.post(["https://api.foursquare.com/v2/checkins/?/reply",newLocation[:checkin_id]], :query => {:text => fsqMsg})
    end
  end
  
  private
    #TODO: Implement this function if we want push notifications to go out for the user.
    def broadcastLocationToFriends(newLocation,user)
      #user.followers.each do |follower|
      #  follower.sendPushNotification()
      #end
    end
  
  
  
end
