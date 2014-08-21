class AddTokenColumnsToCards < ActiveRecord::Migration
  def change
    add_column :cards, :profile_id, :string
    add_column :cards, :payment_profile_id, :string
  end
end
