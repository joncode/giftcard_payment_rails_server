class CreateBulkContacts < ActiveRecord::Migration
  def change
    create_table :bulk_contacts do |t|
      t.integer :user_id
      t.text :data

      t.timestamps
    end
  end
end
