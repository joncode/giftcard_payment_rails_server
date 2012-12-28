class AddRetailToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :retail, :boolean, :default => true
  end
end
