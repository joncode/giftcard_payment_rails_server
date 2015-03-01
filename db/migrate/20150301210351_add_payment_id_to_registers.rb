class AddPaymentIdToRegisters < ActiveRecord::Migration
  def change
  	add_column :registers, :payment_id, :integer
  end
end
