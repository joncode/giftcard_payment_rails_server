class AddStatusToRedemptions < ActiveRecord::Migration
  def change
  	add_column :redemptions, :status, :string, default: 'pending'
  end
end
