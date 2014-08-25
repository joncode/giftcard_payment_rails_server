class AddIndexOnProtoIdToBulkEmails < ActiveRecord::Migration
  def change
  	add_index :bulk_emails, :proto_id
  end
end
