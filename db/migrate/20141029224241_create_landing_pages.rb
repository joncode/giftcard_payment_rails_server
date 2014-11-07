class CreateLandingPages < ActiveRecord::Migration
	def change
		create_table :landing_pages do |t|
			t.integer :campaign_id
			t.integer :affiliate_id
			t.string :title
			t.string :banner_photo_url
			t.integer :example_item_id
			t.json :page_json
			t.string :sponsor_photo_url
			t.string :link
			t.timestamps
		end

		add_index :landing_pages, :link
	end
end
