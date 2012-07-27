class AddCategoryToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :category, :string
  end
end
