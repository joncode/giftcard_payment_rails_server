class CreateAppContacts < ActiveRecord::Migration
  def change
    create_table :app_contacts do |t|
      t.integer :user_id
      t.string :network
      t.string :network_id
      t.string :name
      t.date :birthday
      t.string :handle

      t.timestamps
    end
  end
end
