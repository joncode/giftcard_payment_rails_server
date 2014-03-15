class DropTableCampaigns < ActiveRecord::Migration
  def up
    drop_table :campaigns
  end

  def down
    # do nothing
  end
end
