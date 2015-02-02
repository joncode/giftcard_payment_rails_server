class AddBalanceToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :balance, :integer
  end
end
