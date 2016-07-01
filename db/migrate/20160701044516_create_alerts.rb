class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string :name
      t.string :system

      t.timestamps null: false
    end
    add_index :alerts, :name
  end
end
