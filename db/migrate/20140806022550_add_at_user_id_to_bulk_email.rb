class AddAtUserIdToBulkEmail < ActiveRecord::Migration
  def change
    add_column :bulk_emails, :at_user_id, :integer
    add_index :bulk_emails, :at_user_id
  end
end
