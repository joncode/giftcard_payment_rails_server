class AddRateToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :rate, :decimal
  end
end
