class AddGiftEmailsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :email_reminder_gift_receiver, :boolean, default: true
    add_column :settings, :email_reminder_gift_giver, :boolean, default: true
  end
end
