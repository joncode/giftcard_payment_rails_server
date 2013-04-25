class AddTokenToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :token, :string
  end
end
