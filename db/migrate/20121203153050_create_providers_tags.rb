class CreateProvidersTags < ActiveRecord::Migration
  	def change
		create_table :providers_tags, id: false do |t|
			t.integer :provider_id
			t.integer :tag_id
		end

		add_index :providers_tags, :provider_id
		add_index :providers_tags, :tag_id
  	end

end
