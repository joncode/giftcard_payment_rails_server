class AddTokenToMenuItems < ActiveRecord::Migration
  def change
  	add_column :menu_items, :token, :string
  end
end
