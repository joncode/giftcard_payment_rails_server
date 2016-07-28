class CreatePlaceGraphs < ActiveRecord::Migration
  def change
    create_table :place_graphs do |t|
      t.integer :place_id
      t.string :place_type
      t.integer :parent_id
      t.string :parent_type

      t.timestamps null: false
    end

    add_index :place_graphs, :place_id
    add_index :place_graphs, :parent_id
    add_index :place_graphs, [:place_id, :parent_id], unique: true
    add_index :place_graphs, [:place_type, :parent_id]
    add_index :place_graphs, [:place_id, :parent_type]
  end
end
