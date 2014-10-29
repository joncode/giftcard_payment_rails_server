class AffiliatesGifts < ActiveRecord::Migration
  	def change
  		create_table :affiliates_gifts, :id => false do |t|
      		t.integer :affiliate_id
      		t.integer :gift_id
      		t.integer :landing_page_id
    	end

    	add_index :affiliates_gifts, :affiliate_id
      	add_index :affiliates_gifts, :gift_id
  	end
end
