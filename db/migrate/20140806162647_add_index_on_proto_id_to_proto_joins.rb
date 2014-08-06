class AddIndexOnProtoIdToProtoJoins < ActiveRecord::Migration
  def change
  	add_index :proto_joins, :proto_id
  end
end
