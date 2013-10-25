class RemoveBankInfoFromProviders < ActiveRecord::Migration
  def up
    remove_column :providers, :account_name
    remove_column :providers, :aba
    remove_column :providers, :routing
    remove_column :providers, :bank_account_name
    remove_column :providers, :bank_address
    remove_column :providers, :bank_city
    remove_column :providers, :bank_state
    remove_column :providers, :bank_zip
  end

  def down
    add_column :providers, :account_name,   :string
    add_column :providers, :aba,    :string
    add_column :providers, :routing,    :string
    add_column :providers, :bank_account_name,  :string
    add_column :providers, :bank_address,   :string
    add_column :providers, :bank_city,  :string
    add_column :providers, :bank_state,     :string
    add_column :providers, :bank_zip,   :string
  end
end
