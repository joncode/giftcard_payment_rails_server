class AddRecNameToProtoJoins < ActiveRecord::Migration
  def change
    add_column :proto_joins, :rec_name, :string
  end
end
