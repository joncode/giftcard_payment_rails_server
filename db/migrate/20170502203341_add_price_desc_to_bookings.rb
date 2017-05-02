class AddPriceDescToBookings < ActiveRecord::Migration
  def change
  	add_column :bookings, :price_desc, :string
  end
end
