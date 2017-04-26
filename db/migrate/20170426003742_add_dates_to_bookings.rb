class AddDatesToBookings < ActiveRecord::Migration
	def change
		add_column :books, :merchant_id, :integer

		add_column :bookings, :link_id, :string
		add_column :bookings, :status, :string, default: 'no_date'
		add_column :bookings, :origin, :string
		add_column :bookings, :date1, :datetime
		add_column :bookings, :date2, :datetime
		add_column :bookings, :event_at, :datetime
	end
end

