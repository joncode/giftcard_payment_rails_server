class CreateSocials < ActiveRecord::Migration
  def change
    create_table :socials do |t|
      t.string :network_id
      t.string :network

      t.timestamps
    end
    add_index :socials, [:network_id, :network]
  end
end
