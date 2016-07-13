class AddSenderToProtoJoins < ActiveRecord::Migration
  def change
    add_column :proto_joins, :send_user_id, :integer
    add_column :proto_joins, :send_user_type, :string
  end
end
