class AddPayStatRedeemedAtIndexesToGifts < ActiveRecord::Migration
  def change
  	add_index :gifts, [:redeemed_at, :pay_stat]
  end
end
