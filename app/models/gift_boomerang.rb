class GiftBoomerang < Gift

    def self.create args={}

        args["payable"] = Gift.find(args["old_gift_id"])
        args.delete("old_gift_id")

        if args["payable"].giver.active == false
            return 'Boomerang does not gift to non-active users'
        end

        gift = super
        if gift.persisted?
            gift.messenger_boomerang
        end
        gift
    end

#   -------------

    def original_receiver_social

        #### WHY DOES THIS WRAPPER EXIST AT ALL ?

        receiver_social_from_gift(self)
    end

private

    def pre_init args={}
        boom = Boomerang.giver
        old_gift         = args["payable"]
        args["cat"]      = boomerang_cat(old_gift.cat)
        args["giver_name"] = boom.name
        args["giver"]    = boom
        args["message"]  = boomerang_message(old_gift)
        args["detail"]   = old_gift.detail
        args["merchant"] = old_gift.merchant
        args["value"]    = old_gift.value
        args["service"]  = old_gift.service
        args["cost"]     = old_gift.cost if old_gift.cost
        args["shoppingCart"] = old_gift.shoppingCart
        args["pay_stat"]     = old_gift.pay_stat
        remove_receiver_data_and_add_old_gift_giver_as_receiver(args)
        args["receiver"] = old_gift.giver
        args['brand_card'] = old_gift.brand_card
        args
    end

    def boomerang_cat(cat)
        cat_s   = cat.to_s
        new_cat = cat_s[0..1] + "7"
        new_cat.to_i
    end

    def boomerang_message gift
        "Here is the gift you sent to #{receiver_social_from_gift(gift)}. They never created an account, so we’re returning this gift to you. Use Regift to try your friend again, send it to a new friend, or use the gift yourself!"
    end

    def receiver_social_from_gift gift
        if gift.receiver_email.present?
            str = gift.receiver_email
        elsif gift.receiver_phone.present?
            str = number_to_phone(gift.receiver_phone)
        else
            str = ''
        end
        gift.receiver_name.to_s + ' ' + str
    end

    def remove_receiver_data_and_add_old_gift_giver_as_receiver(args)
        ["receiver_name", "receiver_email", "receiver_phone", "twitter", "facebook_id"].each { |key| remove_text(args,key) }
    end

    def remove_text args, key
        if args[key]
            args.delete(key)
        end
    end

end# == Schema Information
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

