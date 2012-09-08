class AddReGiftToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :re_gift_id, :integer
  end
end
