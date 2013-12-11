class AddExpirationDatesAndRefundsToGifts < ActiveRecord::Migration
  def up
    add_column :gifts, :refund_id,  :integer
    add_column :gifts, :refund_type, :string
    add_column :gifts, :expires_at, :datetime
  end

  def down
    remove_column :gifts, :expires_at
    remove_column :gifts, :refund_id
    remove_column :gifts, :refund_type
  end
end
