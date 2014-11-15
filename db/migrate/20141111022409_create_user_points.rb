class CreateUserPoints < ActiveRecord::Migration
  def change
    create_table :user_points do |t|
      t.integer :user_id
      t.integer :region_id, default: 0
      t.integer :points, default: 0

      t.timestamps
    end

    add_index :user_points, :region_id
    add_index :user_points, [:region_id, :points]
    add_index :user_points, [:region_id, :user_id]
  end
end
