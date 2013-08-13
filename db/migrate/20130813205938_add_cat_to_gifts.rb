class AddCatToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :cat, :integer, :default => 0
  end
end
