class AddGiftEmailsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :gift_reminder, :boolean
    add_column :settings, :gift_not_received, :boolean
  end
end
