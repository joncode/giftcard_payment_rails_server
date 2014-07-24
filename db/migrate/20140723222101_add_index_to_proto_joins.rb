class AddIndexToProtoJoins < ActiveRecord::Migration
  def change

  	add_index :proto_joins, [:receivable_id, :proto_id]
  end
end

