class AddNewStatusToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :stat, :integer
    add_column :gifts, :pay_stat, :integer
    add_column :gifts, :pay_type, :string
    add_column :gifts, :pay_id, :integer
    add_column :gifts, :notified_at, :datetime
    add_column :gifts, :notified_at_tz, :string
    add_column :gifts, :redeemed_at, :datetime
    add_column :gifts, :redeemed_at_tz, :string
    add_column :gifts, :server_code, :string
  end
end
