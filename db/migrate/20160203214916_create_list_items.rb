class CreateListItems < ActiveRecord::Migration
  def change
    create_table :list_items do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :list_step_id
      t.string :state, default: ""

      t.timestamps null: false
    end
  end
end
