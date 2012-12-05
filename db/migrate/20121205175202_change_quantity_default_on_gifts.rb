class ChangeQuantityDefaultOnGifts < ActiveRecord::Migration
  def up
  	change_column_null(:gifts, :quantity, nil)
  end

  def down
  end
end
