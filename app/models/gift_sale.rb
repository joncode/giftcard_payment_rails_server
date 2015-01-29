class GiftSale < Gift
    include GiftMessenger

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

        args["card"]  = args["giver"].cards.where(id: args["credit_card"]).first

        if args["card"].nil?
            return "We do not have that credit card on record.  Please choose a different card."
        end
        gift = super
        if gift.pay_stat == "payment_error"
            gift.payable.reason_text
        else
            if gift.persisted?
                gift.messenger(:invoice_giver)
                Resque.enqueue(GiftCreatedEvent, gift.id)
            end
            gift
        end
    end

private

    def pre_init args={}
        args["unique_id"] = unique_cc_id(args["receiver_name"], args["provider_id"])
        card                           = args["card"]
        args["amount"]                 = (args["value"].to_f + set_service_f(args)).to_s
        args["cost"]                   = (args["value"].to_f * 0.85).to_s
        credit_card_hsh                = card.create_card_hsh(args, args["giver"].cim_profile)
        credit_card_hsh["giver_id"]    = card.user_id
        credit_card_hsh["provider_id"] = args["provider_id"]
        args["cat"]                    = set_cat(args)
        args["payable"] = Sale.charge_card credit_card_hsh
        args.delete("unique_id")
        args.delete("card")
        args.delete("amount")
    end

    def set_service_f(args)
        service_f       = args["value"].to_f * 0.05
        args['service'] = float_to_cents(service_f)
        service_f
    end

    def unique_cc_id receiver_name, provider_id
        "#{receiver_name}_#{provider_id}".gsub(' ','_')
    end

    def set_cat args
        if args["cat"] && args["cat"].class == Fixnum
            args["cat"]
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

