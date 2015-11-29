class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
    	t.integer :user_id
    	t.integer :menu_item_id
    	t.string :user_action
    	t.string :network_id
    end
  end
end
