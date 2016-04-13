class GiftSale < Gift

    def self.create args={}
        args["receiver_name"] = args["receiver_name"].gsub(/[^0-9a-z ]/i, '') if args["receiver_name"]
        if args["receiver_id"]
            receiver = User.unscoped.find(args["receiver_id"])
            if receiver.active == false
                return 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
            else
                args["receiver"] = receiver
            end
        end

        @card = args["giver"].cards.where(id: args["credit_card"]).first

        if @card.nil?
            return "We do not have that credit card on record.  Please choose a different card."
        end
        gift = super

        if gift.pay_stat == "payment_error"
            return gift.payable.reason_text || 'payment_error - credit card system down , please try again shortly'
        else
            if gift.persisted?
                gift.messenger(:invoice_giver)
            end
            return gift
        end
    end

private

    def pre_init args={}

        args["cat"] = set_cat(args["cat"])

        merchant_id = args['merchant_id'] || args["provider_id"]
        merchant = Merchant.find(merchant_id)
        args['merchant_id'] = merchant_id

            # this should occur in Gift.rb
        args["cost"] = (args["value"].to_f * merchant.location_fee.to_f).to_s
        args['service'] = float_to_cents(args["value"].to_f * 0.05)

        validateGift = Gift.new(args)
        if validateGift.valid?

            charge_amount = (args["value"].to_f + args['service'].to_f)).to_s
            unique_charge_id = unique_cc_id(args["receiver_name"], merchant_id, @card.user_id)
            card_to_sale_hsh = @card.sale_hsh_from_card(
                    charge_amount,
                    unique_charge_id,
                    args["giver"].cim_profile,
                    merchant_id
                )
            args["payable"] = Sale.charge_card card_to_sale_hsh

        else
            puts "\n  GIFT INVALID SUBMITTED 500 Internal \n #{args.inspect} \n"
            validateGift
        end

    end

    def unique_cc_id receiver_name, merchant_id, user_id
        "r-#{receiver_name}+m-#{merchant_id}+u-#{user_id}".gsub(' ','_')
    end

    def set_cat args_cat
        if args_cat && args_cat.class == Fixnum
            args_cat
        else
            300
        end
    end

end

# Step 1 - reject suspended / de-active users
# Step 2 - reject card not found
# Step 3 - create revenue
# Step 4 - build the Sale record
#     A1 - build the charge card hash
#     xA2 - create the gift unique_id
#     B - process the credit card thru payment_gateway
#     C - populate the sale_object with the payment_gateway response
#     D - add the card_id to sale_object
# Step 5 - add sale_object to args["payable"]
# Step 6 - remove unneeded keys from args
# Step 7 - call super -> Gift#create
# Step 8 - send messages

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

