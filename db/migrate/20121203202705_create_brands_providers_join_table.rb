class CreateBrandsProvidersJoinTable < ActiveRecord::Migration
  	def change
		create_table :brands_providers, id: false do |t|
			t.integer :provider_id
			t.integer :brand_id
		end

		add_index :brands_providers, :provider_id
		add_index :brands_providers, :brand_id
  	end
end
