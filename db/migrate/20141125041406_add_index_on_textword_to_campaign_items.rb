class AddIndexOnTextwordToCampaignItems < ActiveRecord::Migration
  def change
  	add_index :campaign_items, :textword
  end
end
