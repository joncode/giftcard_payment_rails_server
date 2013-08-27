class AddActiveToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :active, :boolean, default: true
  end
end
