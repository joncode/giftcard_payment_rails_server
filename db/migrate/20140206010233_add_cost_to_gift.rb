class AddCostToGift < ActiveRecord::Migration
  def change
    add_column :gifts, :cost, :string
  end
end
