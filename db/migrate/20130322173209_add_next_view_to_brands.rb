class AddNextViewToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :next_view, :string
    rename_column :brands, :banner, :photo
  end
end
