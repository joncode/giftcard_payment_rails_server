class GiftSale < Gift


# {"receiver_name"=>"Richard", "receiver_email"=>"hkosoff@gmail.com", "link"=>nil,
# "origin"=>"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0",
 # "client_id"=>120, "partner_id"=>571, "partner_type"=>"Merchant",
 # "shoppingCart"=>[{"price"=>"30", "quantity"=>2, "item_id"=>5370, "item_name"=>"18 Holes (Weekdays)"}],
  # "giver"=>@user,
  # "credit_card"=>980195261, "merchant_id"=>571, "value"=>"60", "message"=>"Happy Chanukah\nLove your favorite Golf Conscierge", "scheduled_at"=>"2016-12-16"}


#   -------------


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

        args['card'] = args["giver"].cards.unscoped.where(id: args["credit_card"]).first

        if args['card'].nil?
            return "We do not have that credit card on record.  Please choose a different card."
        elsif args['card'].expired?
            return "Card #{args['card'].nickname} is expired. Please choose or upload a new card."
        elsif !args['card'].active
            return "Card #{args['card'].nickname} is deactivated. Please choose or upload a new card."
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

        if args["shoppingCart"].kind_of?(Array)
            args["shoppingCart"] = args["shoppingCart"].to_json
        end
        args["cat"] = set_cat(args["cat"])

        merchant_id = args['merchant_id'] || args["provider_id"]
        merchant = Merchant.find(merchant_id)
        args['merchant_id'] = merchant_id
        args['ccy'] = merchant.ccy

            # this should occur in Gift.rb
        args["cost"] = (args["value"].to_f * merchant.location_fee.to_f).round(2).to_s
        args['service'] = float_to_money(args["value"].to_f * 0.05)

        validateGift = Gift.new(args)
        if validateGift.valid?

            charge_amt = charge_amount(args['giver'], args["value"], args['service'])
            unique_charge_id = unique_cc_id(args["receiver_name"], merchant_id, args['card'].user_id)
            card_to_sale_hsh = args['card'].sale_hsh(
                    charge_amt,
                    args['ccy'],
                    unique_charge_id,
                    args["giver"].cim_profile,
                    merchant_id
                )
            args.delete('card')
            card_to_sale_hsh['destination_hsh'] = merchant.destination_hsh(args["cost"])
            args["payable"] = Sale.charge_card(card_to_sale_hsh, args["giver"])

        else
            puts "\n  GIFT INVALID SUBMITTED 500 Internal \n #{args.inspect} \n"
            validateGift
        end

    end

    def charge_amount giver, value_string, service_string
        usr_coupons = giver.coupons
        if usr_coupons.present? && usr_coupons[1]
            value = value_string.to_f * usr_coupons[1].to_f
            service = 0.0
            puts "GiftSale(93) COUPON APPLIED #{value_string} -> #{value} | #{service_string} -> #{service}"
            value.round(2).to_s
        else
            (value_string.to_f + service_string.to_f).to_s
        end
    end

    def unique_cc_id receiver_name, merchant_id, user_id
        "r-#{receiver_name}|m-#{merchant_id}|u-#{user_id}".gsub(' ','_')
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


 # {"data"=>
 #    {"items"=>
 #        [{"price"=>"50",
 #            "item_name"=>"18 Holes of Golf",
 #            "item_id"=>3999, "quantity"=>1}],
 #     "service"=>"2.5", "value"=>"50",
 #     "loc_id"=>379, "pay_id"=>e,
 #     "rec_name"=>"Sam", "msg"=>nil,
 #     "rec_net"=>"em", "rec_net_id"=>"sam@smith.com"}
 # }

# {"receiver_name"=>"Jonny",
#     "receiver_email"=>"m80dubstation@gmail.com",
#  "link"=>nil, "origin"=>"RestSharp 104.1.0.0",
#  "client_id"=>1, "partner_id"=>17, "partner_type"=>"Affiliate",
#  "shoppingCart"=>[{"price"=>"50",
#  "quantity"=>1, "item_id"=>3999, "item_name"=>"18 Holes of Golf"}],

#   "giver"=><User id: 841, email: "sam@smith.com", password_digest: "$2a$10$peQPtVbQxvpZMik2VgdNq.3FjlJqTr/0gUf/fGGcWx5...",
#   remember_token: "5JsfTzBasqrPAxafJa7VXw", created_at: "2015-10-05 01:08:20", updated_at: "2016-05-16 07:54:07",
#   address: nil, address_2: nil, city: nil, state: nil, zip: "98101", phone: nil, first_name: "Sam",
#   last_name: "Smith", facebook_id: "503107738", handle: nil, twitter: nil, active: true, persona: "",
#   sex: "male", is_public: nil, iphone_photo: "https://graph.facebook.com/503107738/picture",
#   reset_token_sent_at: "2016-05-16 07:54:07", reset_token: "26e44b504db13c9300bf6d9027a7cbe7",
#   birthday: "1982-06-12", origin: nil, confirm: "00", perm_deactive: false, cim_profile: "37679558",
#   ftmeta: "'841':1A '98101':5C 'sam':3B 'sam@smith.com':2B 's...", affiliate_url_name: nil, partner_id: 17,
#   partner_type: "Affiliate", client_id: 1>,

# "credit_card"=>566, "merchant_id"=>379, "value"=>"50",
#  "message"=>"testing multi currency",
#  "scheduled_at"=>nil}

