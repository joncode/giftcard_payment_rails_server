class ChangePriceDescToPriceNameOnBookings < ActiveRecord::Migration
  def change
  	rename_column :bookings, :price_desc, :price_name
  end
end
