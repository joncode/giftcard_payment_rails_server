class AddIndexToHexIdOnBookings < ActiveRecord::Migration
  def change
  	add_index :bookings, :hex_id
  end
end
