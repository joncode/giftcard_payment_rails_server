class AddPaymentEventEnumToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :payment_event, :integer, default: 0
    add_column :merchants, :payment_event, :integer, default: 0
  end
end
