class AddRevenueCentsAndGatewayToSales < ActiveRecord::Migration
	include MoneyHelper
	def change
		add_column :sales, :revenue_cents, :integer
		add_column :sales, :gateway, :string
		set_cents_and_gateway
	end

	def set_cents_and_gateway
		Sale.find_each do |sale|
			rev = sale.revenue.to_s
			cents = currency_to_cents(rev)
			sale.update_column(:revenue_cents, cents)
			sale.update_column(:gateway, 'authorize')
		end
	end
end
