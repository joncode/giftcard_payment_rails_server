class AddClicksToClients < ActiveRecord::Migration
  def change
    add_column :clients, :clicks, :integer, default: 0
  end
end
