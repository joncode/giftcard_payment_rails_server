class RenameGroupOnPrintQueues < ActiveRecord::Migration
  def change
  	# remove_index :print_queues. :group
  	rename_column :print_queues, :group, :job
  end
end
