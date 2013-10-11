class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
        t.integer :campaign_id
        t.timestamps
    end
  end
end
