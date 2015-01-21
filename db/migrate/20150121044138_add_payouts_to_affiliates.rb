class AddPayoutsToAffiliates < ActiveRecord::Migration
  def change
  	add_column :affiliates, :total_merchants, :integer, default: 0
  	add_column :affiliates, :payout_merchants, :integer, default: 0
  	add_column :affiliates, :total_users, :integer, default: 0
  	add_column :affiliates, :payout_users, :integer, default: 0
  end
end
