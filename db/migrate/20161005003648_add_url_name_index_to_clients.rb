class AddUrlNameIndexToClients < ActiveRecord::Migration
  def change
  	add_index :clients, [:url_name, :active]
  end
end
