class AddCcyAndUsdCentsToSales < ActiveRecord::Migration
	def change
		add_column :sales, :ccy, :string
		add_column :sales, :usd_cents, :integer
	end
	remove_index :sales, :provider_id
end
