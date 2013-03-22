class AddNextViewToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :next_view, :string
  end
end
