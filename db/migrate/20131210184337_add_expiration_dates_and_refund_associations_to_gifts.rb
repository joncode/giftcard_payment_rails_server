class AddExpirationDatesAndRefundAssociationsToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :expires_at, :datetime
    add_column :gifts, :refund_id, :integer
    add_column :gifts, :refund_type, :string
  end
end
