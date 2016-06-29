class AddStripeIdsToCardsAndUsers < ActiveRecord::Migration
  def change
    add_column :cards, :country, :string
    add_column :cards, :stripe_user_id, :string
    add_column :cards, :stripe_id, :string
    add_column :cards, :address, :string
    add_column :users, :stripe_id, :string
  end
end
