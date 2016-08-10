class CreateListGraphs < ActiveRecord::Migration
  def change
    create_table :list_graphs do |t|
      t.integer :list_id
      t.integer :target_id
      t.string :target_type
      t.integer :position
      t.boolean :active

      t.timestamps null: false
    end
  end
end
