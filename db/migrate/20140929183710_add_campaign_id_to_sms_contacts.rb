class AddCampaignIdToSmsContacts < ActiveRecord::Migration
  def change
    add_column :sms_contacts, :campaign_id, :integer
    add_index :sms_contacts, [:campaign_id, :textword, :gift_id]
    remove_index :sms_contacts, :subscribed_date
  end
end
