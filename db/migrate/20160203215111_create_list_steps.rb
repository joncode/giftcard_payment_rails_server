class CreateListSteps < ActiveRecord::Migration
  def change
    create_table :list_steps do |t|
      t.string :name
      t.string :type_of
      t.string :owner_type
      t.integer :position, default: 0

      t.timestamps null: false
    end
  end
end
