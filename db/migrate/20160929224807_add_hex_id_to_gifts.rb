class AddHexIdToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :hex_id, :string
    add_index :gifts, :hex_id
    remove_index :gifts, [:provider_id , :created_at]
	remove_index :gifts, [:provider_id , :status]
	remove_index :gifts, :provider_id
  end
end
