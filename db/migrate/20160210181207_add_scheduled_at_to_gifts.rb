class AddScheduledAtToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :scheduled_at, :datetime
    add_column :protos, :scheduled_at, :datetime
    add_column :campaign_items, :scheduled_at, :datetime
  end
end
