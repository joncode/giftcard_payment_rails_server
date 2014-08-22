class AddTokenColumnsToCards < ActiveRecord::Migration
  def change
    add_column :cards, :cim_token, :string
    add_column :users, :cim_token, :string
  end
end
