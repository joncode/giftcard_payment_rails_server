class AddExpirationDatesAndRefundAssociationsToGifts < ActiveRecord::Migration
  def up
    add_column :gifts, :expires_at, :datetime
    add_column :gifts, :refund_id,  :integer
    add_column :gifts, :refund_type, :string
  end

  def down
    remove_column :gifts, :expires_at
    remove_column :gifts, :refund_id
    remove_column :gifts, :refund_type
  end
end
