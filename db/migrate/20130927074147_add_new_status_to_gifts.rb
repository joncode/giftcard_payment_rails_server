class AddNewStatusToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :pay_stat,    :string
    add_column :gifts, :pay_type,    :string
    add_column :gifts, :pay_id,      :integer
    add_column :gifts, :redeemed_at, :datetime
    add_column :gifts, :server,      :string

    add_index :gifts, :status
    add_index :gifts, :pay_stat
  end
end
