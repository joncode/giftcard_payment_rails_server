class AddStatusAndAdjustsToPayments < ActiveRecord::Migration

	def change
		add_column :payments, :status, :string, default: 'NEG'
		add_column :payments, :adjusts, :integer, default: 0

		add_index :payments, :status
		add_index :payments, [ :status, :bank_id ]

		set_status_on_payments
	end

	def set_status_on_payments
		Payment.find_each do |payment|
			if payment.partner_type == 'Merchant' && (payment.partner.mode == 'paused' || !payment.partner.active)
				payment.update_column :status, 'HOLD'
			elsif payment.total <= 0
				# payment.update_column :status, 'NEG'
			elsif payment.paid
				payment.update_column :status, 'PAID'
			else
				payment.update_column :status, 'DUE'
			end
		end
	end

end


	# - add :adjusts to payemnt.rb, default to 0 , takes negative integers
	# - add :status to payment.rb, default to, 'NEG', also can be 'PAID', "DUE", 'HOLD'