class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.string :detail
      t.integer :state_id
      t.integer :city_id
      t.string :photo
      t.boolean :active, default: true
      t.integer :type_of, default: 0
      t.string :token

      t.timestamps
    end

    add_index :regions, [:city_id, :active]
    add_index :regions, :active
  end
end
