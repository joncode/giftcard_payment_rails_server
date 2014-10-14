class AddViewedAtOrderedAtAndTokenToGifts < ActiveRecord::Migration
  def up
	add_column 	  :gifts, :viewed_at, 	:datetime
	add_column 	  :gifts, :ordered_at, 	:datetime
  end

  def down
	remove_column :gifts, :viewed_at
	remove_column :gifts, :ordered_at
  end
end
