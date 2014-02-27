class RemoveOldAttributesFromGifts < ActiveRecord::Migration
  def up
    remove_column :gifts, :foursquare_id
    remove_column :gifts, :pay_type
    remove_column :gifts, :tax
    remove_column :gifts, :tip
    remove_column :gifts, :pay_id
    remove_column :gifts, :sale_id
    remove_column :gifts, :regift_id
  end

  def down
    add_column :gifts, :foursquare_id, :string
    add_column :gifts, :pay_type, :string
    add_column :gifts, :tax, :string
    add_column :gifts, :tip, :string
    add_column :gifts, :pay_id, :integer
    add_column :gifts, :sale_id, :integer
    add_column :gifts, :regift_id, :integer
  end
end
