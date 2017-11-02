class CreateSupplyItems < ActiveRecord::Migration
	def change
		create_table :supply_items do |t|
			t.string :hex_id
			t.string :name
			t.integer :price
			t.string :ccy, default: 'USD'
			t.string :detail
			t.string :photo_url
			t.boolean :active, default: true

			t.timestamps null: false
		end

		seed_supply_items
	end

	def seed_supply_items
		[{
		    name: "Epson Printer (TN-T88VI)",
		    price: 55000,
		    ccy: 'USD'
		},{
		    name:    "100 Check Presenters",
		    price: 650,
		    ccy: 'USD'
		},{
		    name:  "50 Table Tents",
		    price: 1000,
		    ccy: 'USD'
		}].map { |s| SupplyItem.create s }
	end

end
