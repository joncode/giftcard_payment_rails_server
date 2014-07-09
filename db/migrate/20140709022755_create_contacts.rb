class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string 	 :network_id
      t.string   :network
      t.timestamps
    end
    add_index :contacts, [:network_id, :network]
  end
end
