class CreateBookings < ActiveRecord::Migration
	def change
		create_table :bookings do |t|
			t.boolean :active, default: true
			t.string :hex_id
			t.string :name
			t.string :email
			t.string :phone
			t.integer :guests
			t.json :dates
			t.json :payments
			t.integer :book_id
			t.integer :price_unit
			t.text :note

			t.timestamps null: false
		end
	end
end
