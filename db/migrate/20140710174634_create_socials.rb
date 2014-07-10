class CreateSocials < ActiveRecord::Migration
  def change
    create_table :socials do |t|
      t.integer :network_id
      t.string :network

      t.timestamps
    end
    add_index :contacts, [:network_id, :network]
  end
end
