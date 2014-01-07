class AddGiftEmailsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :gift_reminder, :boolean, default: true
    add_column :settings, :gift_not_received, :boolean, default: true
  end
end
