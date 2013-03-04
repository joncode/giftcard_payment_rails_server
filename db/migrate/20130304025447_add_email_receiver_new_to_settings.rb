class AddEmailReceiverNewToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :email_receiver_new, :boolean
  end
end
