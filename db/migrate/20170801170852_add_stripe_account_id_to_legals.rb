class AddStripeAccountIdToLegals < ActiveRecord::Migration
  def change
  	add_column :legals, :stripe_account_id, :string
  end
end
