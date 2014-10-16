class AddNotifiedAtNewTokenAtToGifts < ActiveRecord::Migration
  def up
	add_column 	  :gifts, :notified_at, 	:datetime
	add_column 	  :gifts, :new_token_at, 	:datetime
	set_notified_at
	set_new_token_at
	return_gifts_with_bad_server_codes
  end

  def down
	remove_column :gifts, :notified_at
	remove_column :gifts, :new_token_at
  end

      def set_notified_at
        Gift.unscoped.find_in_batches do |group|
            group.each do |gift|
                if redeem = gift.redeem
                    gift.update_column(:notified_at, redeem.created_at)
                end
            end
        end
        nil
    end

    def set_new_token_at
        Gift.unscoped.where(status: 'redeemed').find_in_batches do |group|
            group.each do |gift|
                if gift.notified_at && gift.notified_at > (gift.redeemed_at - 1.day)
                    gift.update_column(:new_token_at, gift.notified_at)
                else
                    gift.update_column(:new_token_at, gift.redeemed_at)
                end
            end
        end
        nil
    end

    def return_gifts_with_bad_server_codes
        oss = Order.where('created_at > ?', '2013-10-14 05:27:40.675624')
        oss.select do |ord|
            if gift = ord.gift
                gift.server != ord.server_code
            else
                false
            end
        end
    end
end
