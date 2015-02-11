class AddBalanceToGifts < ActiveRecord::Migration
  def up
    add_column :gifts, :balance, :integer

    set_balance_to_value
  end

  def down
  	remove_column :gifts, :balance
  end

  def set_balance_to_value
  	# Gift.find_in_batches do |group|
  	# 	group.each do |gift|
  	# 		value = gift.read_attribute(:value)
  	# 		gift.update(balance: (value.to_f.round(2) * 100).to_i)
  	# 	end
  	# end
  end
end
