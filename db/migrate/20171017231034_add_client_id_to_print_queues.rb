class AddClientIdToPrintQueues < ActiveRecord::Migration
  def change
  	add_column :print_queues, :client_id, :string
  end
end
