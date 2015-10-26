class AddBankIdToPayments < ActiveRecord::Migration
  def change
  	add_column :payments, :bank_id, :integer
   	add_index :payments, [:bank_id, :start_date]
  end
end
