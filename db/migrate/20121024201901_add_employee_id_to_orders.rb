class AddEmployeeIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :employee_id, :integer
  end
end
