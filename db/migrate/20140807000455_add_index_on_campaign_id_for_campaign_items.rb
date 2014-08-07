class AddIndexOnCampaignIdForCampaignItems < ActiveRecord::Migration
  def change
   	add_index :campaign_items, :campaign_id
  end
end
