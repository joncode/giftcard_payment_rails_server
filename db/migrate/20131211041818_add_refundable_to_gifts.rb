class AddRefundableToGifts < ActiveRecord::Migration
  def up
    puts " refundables migration commented ouT - need refund sale code ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    # add_column :gifts, :refund_id, :integer
    # add_column :gifts, :refund_type, :string

    # gs = Gift.where(pay_stat: ["refunded", "void"])
    # gs.each do |gift|
    #     # find sales that are refunds
    #     gift.refund = refund_sale
    #     gift.save
    # end
  end

  def down
    # remove_column :gifts, :refund_id
    # remove_column :gifts, :refund_type
  end

end
