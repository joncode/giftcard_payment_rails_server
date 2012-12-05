class AddBrandIdAndSupplierIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :brand_id, :integer
    add_column :items, :supplier_id, :integer
  end
end
