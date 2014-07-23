class CreateBulkEmails < ActiveRecord::Migration
  def change
    create_table :bulk_emails do |t|
      t.text 	:data
      t.boolean :processed, default: false
      t.integer :proto_id
      t.integer :provider_id

      t.timestamps
    end
  end
end
