class AddRefundableToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :refund_id, :integer
    add_column :gifts, :refund_type, :string
  end
end
