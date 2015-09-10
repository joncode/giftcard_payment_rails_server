class GiftPromo < Gift
    include ShoppingCartHelper

#   -------------

    def self.create(args)
        gift = super
        if gift.persisted?
            gift.messenger
        end
        gift
    end


private

    def pre_init args={}
        merchant_id = args['merchant_id'] || args["provider_id"]
        giver           = BizUser.find(merchant_id)
        args["cat"]     = set_cat(args)
        args["giver"]   = giver
        args["value"]   = calculate_value(args["shoppingCart"])
        args["cost"]    = "0"
        args["payable"] = giver.new_debt(args["value"])
    end

    # def post_init args={}
    #     puts "NOTIFY RECEIVER VIA #{self.receiver_email}"
    #     #  alert merchant tools wbesite
    # end

    def set_cat args
        if args["cat"] && args["cat"].class == Fixnum
            args["cat"]
        else
            200
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

