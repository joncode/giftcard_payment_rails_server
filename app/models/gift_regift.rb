class GiftRegift < Gift

    def self.create args={}
        args["receiver_name"] = args["receiver_name"].gsub(/[^0-9a-z ]/i, '') if args["receiver_name"]
        if args["receiver_id"]
            receiver = User.unscoped.find(args["receiver_id"])
            if receiver.active == false
                return 'User is no longer in the system , please gift to them with phone, email, or facebook'
            end
        end
        args["payable"] = Gift.includes(:merchant).includes(:receiver).find(args["old_gift_id"])

        gift = super
        if gift.persisted?
            gift.messenger
            Resque.enqueue(PointsForCompletionJob, gift.id)
        end
        gift
    end

private

    def pre_init args={}
        args.delete("old_gift_id")
        old_gift         = args["payable"]
        args["cat"]      = set_cat(old_gift)
        args["giver"]    = old_gift.receiver if !args["giver"].kind_of?(User)
        args["merchant"] = old_gift.merchant
        if old_gift.payable_type == 'Proto'
            args["detail"]   = old_gift.payable.detail
        else
            args['detail'] = nil
        end
        args["value"] = (old_gift.balance.to_f/100).to_s
        args['balance'] = old_gift.balance
        args["cost"]     = old_gift.cost if old_gift.cost
        args["shoppingCart"] = old_gift.shoppingCart
        args["pay_stat"]   = old_gift.pay_stat
        args["expires_at"] = old_gift.expires_at
        args['brand_card'] = old_gift.brand_card
        user_to_gift_key_names args
    end

    def user_to_gift_key_names args
        ["name", "email", "phone"].each { |key| remove_text(args,key) }
    end

    def remove_text args, key
        if args[key]
            args["receiver_#{key}"] = args[key]
            args.delete(key)
        end
    end

    def set_cat old_gift
        if old_gift.cat.present?
            str = old_gift.cat.to_s
            str[2] == "0" ?  old_gift.cat + 1 : old_gift.cat
        else
            001
        end
    end

end
# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#  origin         :string(255)
#

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#

