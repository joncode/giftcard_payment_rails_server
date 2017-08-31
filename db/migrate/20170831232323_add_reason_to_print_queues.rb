class AddReasonToPrintQueues < ActiveRecord::Migration
  def change
    add_column :print_queues, :reason, :json
  end
end
