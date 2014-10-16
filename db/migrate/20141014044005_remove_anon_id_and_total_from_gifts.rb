class RemoveAnonIdAndTotalFromGifts < ActiveRecord::Migration
  def up
	remove_column :gifts, :anon_id
	remove_column :gifts, :total
  end

  def down
	add_column 	  :gifts, :anon_id, 	:integer
	add_column 	  :gifts, :total, 	:string
  end
end
