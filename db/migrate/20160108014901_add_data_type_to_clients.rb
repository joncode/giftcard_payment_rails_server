class AddDataTypeToClients < ActiveRecord::Migration
  def change
    add_column :clients, :data_type, :integer, default: 0
  end
end
