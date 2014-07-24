class AddContactsAndProcessedToProtos < ActiveRecord::Migration
  def change
    add_column :protos, :contacts, 	:integer, default: 0
    add_column :protos, :processed, :integer, default: 0
  end
end
