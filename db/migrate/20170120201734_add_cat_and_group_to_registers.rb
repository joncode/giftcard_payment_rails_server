class AddCatAndGroupToRegisters < ActiveRecord::Migration
  def change
    add_column :registers, :cat, :string, default: 'ACCRUAL'
    add_column :registers, :group, :string
  end
end
