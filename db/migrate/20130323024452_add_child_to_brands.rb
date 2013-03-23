class AddChildToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :child, :boolean, :default => false
  end
end
