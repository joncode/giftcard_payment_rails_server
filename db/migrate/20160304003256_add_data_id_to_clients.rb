class AddDataIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :data_id, :integer
  end
end
