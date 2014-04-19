class GiftRegift < Gift

    def self.create args={}
        if args["receiver_id"]
            receiver = User.unscoped.find(args["receiver_id"])
            if receiver.active == false
                return 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
            end
        end
        args["payable"] = Gift.includes(:provider).includes(:receiver).find(args["old_gift_id"])

        if args["payable"].promo?
            "You cannot regift a promotional gift"
        else
            gift = super
            gift.messenger
            gift
        end
    end

    def messenger
        puts "REGIFT-post_init -- Notify new Receiver #{self.receiver}"
        puts "REGIFT-post_init -- Invoice the regifter via email #{self.giver}"
        Relay.send_push_notification(self)
        notify_receiver
    end

private

    def pre_init args={}
        args.delete("old_gift_id")
        old_gift         = args["payable"]
        args["cat"]      = set_cat(old_gift)
        args["giver"]    = old_gift.receiver
        args["provider"] = old_gift.provider
        args["value"]    = old_gift.value
        args["cost"]     = old_gift.cost if old_gift.cost
        args["shoppingCart"] = old_gift.shoppingCart
        args["pay_stat"]   = old_gift.pay_stat
        args["expires_at"] = old_gift.expires_at
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
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  tax            :string(255)
#  tip            :string(255)
#  regift_id      :integer
#  foursquare_id  :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  sale_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  pay_type       :string(255)
#  pay_id         :integer
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
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

