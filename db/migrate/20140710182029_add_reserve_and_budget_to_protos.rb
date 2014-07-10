class AddReserveAndBudgetToProtos < ActiveRecord::Migration
  def change
    add_column :protos, :reserve, :integer, default: 0
    add_column :protos, :budget,  :integer, default: 0
  end
end
