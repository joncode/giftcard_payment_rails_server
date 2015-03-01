class AddLinkAmountsAndDefaultsToPayments < ActiveRecord::Migration
  def change
  	change_column :payments, :m_transactions, :integer, default: 0
  	change_column :payments, :m_amount, :integer, default: 0
  	change_column :payments, :u_transactions, :integer, default: 0
  	change_column :payments, :u_amount, :integer, default: 0
  	change_column :payments, :total, :integer, default: 0
  	add_column :payments, :l_transactions, :integer, default: 0
  	add_column :payments, :l_amount, :integer, default: 0
  end
end

