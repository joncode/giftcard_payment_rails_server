class AddEmailReceiverNewToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :email_receiver_new, :boolean, :default => true
  end
end
