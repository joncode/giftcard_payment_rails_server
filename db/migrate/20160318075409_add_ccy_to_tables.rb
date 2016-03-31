class AddCcyToTables < ActiveRecord::Migration
	def change
  		add_column :gifts, :ccy, :string, default: "USD", limit: 6
  		add_column :registers, :ccy, :string, default: "USD", limit: 6
  		add_column :merchants, :ccy, :string, default: "USD", limit: 6
  		add_column :affiliates, :ccy, :string, default: "USD", limit: 6
	end
end
