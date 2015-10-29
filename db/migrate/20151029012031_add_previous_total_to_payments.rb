class AddPreviousTotalToPayments < ActiveRecord::Migration
  def change
  	  	add_column :payments, :previous_total, :integer, default: 0
  end
end
