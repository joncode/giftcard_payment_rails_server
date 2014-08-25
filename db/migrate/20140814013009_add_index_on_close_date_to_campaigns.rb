class AddIndexOnCloseDateToCampaigns < ActiveRecord::Migration
  def change
  	add_index :campaigns, :close_date
  end
end
