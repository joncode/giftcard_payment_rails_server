class AddIndexToUserIdOnCards < ActiveRecord::Migration
  def up
  	add_index :cards, :user_id
  end

  def down
  	remove_index :cards, :user_id
  end
end
