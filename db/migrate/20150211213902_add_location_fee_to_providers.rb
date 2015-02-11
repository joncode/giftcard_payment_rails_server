class AddLocationFeeToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :payment_plan, :integer, default: 0
  end
end
