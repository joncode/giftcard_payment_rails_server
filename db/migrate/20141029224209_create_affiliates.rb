class CreateAffiliates < ActiveRecord::Migration
	def change
		create_table :affiliates do |t|
			t.string :first_name
			t.string :last_name
			t.string :email
			t.string :phone
			t.string :address
			t.string :state
			t.string :city
			t.string :zip
			t.string :url_name
			t.timestamps
		end

		add_index :affiliates, :url_name
	end
end
