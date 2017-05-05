class AddCardInfoToBookings < ActiveRecord::Migration
  def change
	add_column :bookings, :ccy, :string, default: 'USD'
	add_column :bookings, :stripe_id, :string
	add_column :bookings, :stripe_user_id, :string

	remove_column :bookings, :payments, :json
	remove_column :bookings, :dates, :json
  end
end
