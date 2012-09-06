class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.integer  :provider_id
      t.integer  :user_id
      t.string   :clearance
      t.boolean  :active
      t.timestamps
    end
  end
end
