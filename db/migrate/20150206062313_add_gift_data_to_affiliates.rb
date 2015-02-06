class AddGiftDataToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :payout_links, :integer, default: 0
    add_column :affiliates, :value_links, :integer, default: 0
    add_column :affiliates, :value_users, :integer, default: 0
    add_column :affiliates, :value_merchants, :integer, default: 0
    add_column :affiliates, :purchase_links, :integer, default: 0
    add_column :affiliates, :purchase_users, :integer, default: 0
    add_column :affiliates, :purchase_merchants, :integer, default: 0
  end
end
