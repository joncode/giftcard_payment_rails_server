class AddIndexOnCatToGifts < ActiveRecord::Migration
  def change
  	add_index :gifts, :cat
  end
end
