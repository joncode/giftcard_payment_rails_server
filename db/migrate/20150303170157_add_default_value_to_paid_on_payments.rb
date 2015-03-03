class AddDefaultValueToPaidOnPayments < ActiveRecord::Migration
    def up
  	  	change_column :payments, :paid, :boolean, default: false
  	  	add_index :payments, [:paid, :start_date]
  	  	check_paid_records_for_nil_and_set_to_false
    end

    def down
    	# do nothing
    	remove_index :payments, [:paid, :start_date]
    end

    def check_paid_records_for_nil_and_set_to_false
    	ps = Payment.where(paid: nil)
    	ps.each do |p|
    		p.update(paid: false)
    	end
    end
end
