class RemoveFoursquareVenueIdFromLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :foursquare_venue_id
  end

  def down
    add_column :locations, :foursquare_venue_id, :string
  end
end
