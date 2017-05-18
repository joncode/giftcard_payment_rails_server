class AddExpiresAtToBooking < ActiveRecord::Migration
  def change
  	add_column :bookings, :expires_at, :datetime
  end
end
