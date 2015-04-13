class AddPaymentInfoAndContractDateToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :prime_amount, :integer
  	add_column :merchants, :prime_date, :date
  	add_column :merchants, :contract_date, :date
  end
end
