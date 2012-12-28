class AddBrandIdToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :brand_id, :integer
  end
end
