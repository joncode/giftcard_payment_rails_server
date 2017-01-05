class AddCcyToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :ccy, :string, default: 'USD'
  end
end
