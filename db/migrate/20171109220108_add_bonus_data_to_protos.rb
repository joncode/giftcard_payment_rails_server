class AddBonusDataToProtos < ActiveRecord::Migration
  def change
  	add_column :protos, :target_item_id, :integer
  	add_column :protos, :bonus, :boolean, default: false
  	add_column :protos, :photo, :string
  	add_column :protos, :item_photo, :string
  	add_column :protos, :item_detail, :text
  	remove_column :protos, :desc, :string
  	add_index :protos, :target_item_id
  end
end
