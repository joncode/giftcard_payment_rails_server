class AddYelpAndHexIdToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :yelp, :string
  	add_column :merchants, :hex_id, :string
  end
end
