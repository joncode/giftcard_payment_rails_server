class AddStatusToRedemptions < ActiveRecord::Migration
  def change
  	add_column :redemptions, :status, :string, default: 'done'
  end
end
