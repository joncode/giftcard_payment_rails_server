class CreateListGraphs < ActiveRecord::Migration
  def change
    create_table :list_graphs do |t|
      t.integer :list_id
      t.integer :item_id
      t.string :item_type
      t.integer :position
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
