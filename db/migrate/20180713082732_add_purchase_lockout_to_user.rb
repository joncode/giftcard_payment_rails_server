class AddPurchaseLockoutToUser < ActiveRecord::Migration
  def change
    add_column :users, :purchase_lockout_until, :datetime
  end
end
