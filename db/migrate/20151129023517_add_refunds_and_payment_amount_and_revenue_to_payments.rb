class AddRefundsAndPaymentAmountAndRevenueToPayments < ActiveRecord::Migration
	def change
		add_column :payments, :revenue, :integer, default: 0
		add_column :payments, :refund, :integer, default: 0
		add_column :payments, :payment_amount, :integer, default: 0
		set_revenue_and_payment_amount_to_total
	end

	def set_revenue_and_payment_amount_to_total
		ps = Payment.all
		ps.each do |p|
			p.revenue = p.total
			p.payment_amount = p.total
			p.save
		end
	end


end
