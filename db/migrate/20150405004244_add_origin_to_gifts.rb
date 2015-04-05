class AddOriginToGifts < ActiveRecord::Migration
  def change
  	add_column :gifts, :origin, :string
  end
end
