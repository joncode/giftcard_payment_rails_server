class CreatePrintQueues < ActiveRecord::Migration
	def change
		create_table :print_queues, id: :uuid do |t|
			t.integer :merchant_id
			t.integer :redemption_id
			t.string :type_of
			t.string :printer_type, default: 'epson'
			t.string :status, default: 'queue'
			t.string :group

			t.timestamps null: false
		end

		add_index :print_queues, [:merchant_id, :status]
		add_index :print_queues, :group
		add_index :print_queues, :redemption_id
	end
end
