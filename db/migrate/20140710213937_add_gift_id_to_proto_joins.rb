class AddGiftIdToProtoJoins < ActiveRecord::Migration
  	def change
    	add_column :proto_joins, :gift_id, :integer
    	add_index :proto_joins, :gift_id
  	end

end
