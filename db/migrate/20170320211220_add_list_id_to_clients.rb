class AddListIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :list_id, :integer
  end
end
