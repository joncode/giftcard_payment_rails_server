class GiftCampaign < Gift

    validate   :is_giftable

    after_save :update_campaign_expire_date
    after_save :decrement_campaign_item_reserve

    def self.create args={}
        gift = super
        if gift.id.present?
            gift.messenger
        end
        gift
    end

    def messenger
        if self.payable.success?
            Relay.send_push_notification(self)
            puts "GiftCampaign -messenger- Notify Receiver via email #{self.receiver_name}"
            notify_receiver
        end
    end

private

    def pre_init args={}
        campaign_item         = CampaignItem.includes(:campaign).includes(:provider).where(id: args["payable_id"]).first
        campaign              = campaign_item.campaign
        provider              = campaign_item.provider
        args["cat"]           = set_cat(campaign)
        args["shoppingCart"]  = JSON.parse campaign_item.shoppingCart
        args["receiver_name"] = campaign.name if args["receiver_name"].nil?
        args["provider_id"]   = provider.id
        args["provider_name"] = provider.name
        args["payable_id"]    = campaign_item.id
        args["payable_type"]  = "CampaignItem"
        args["value"]         = campaign_item.value
        args["cost"]          = campaign_item.cost
        args["giver_type"]    = "Campaign"
        args["giver_id"]      = campaign.id
        args["giver_name"]    = campaign.name
        args["message"]       = campaign_item.message
        args["expires_at"]    = expires_at_calc(campaign_item.expires_at, campaign_item.expires_in)
    end

    def expires_at_calc expires_at, expires_in
        if expires_at.present?
            expires_at
        elsif expires_in.present?
            Time.now + expires_in.days
        end
    end

    def set_cat campaign
        campaign.gift_cat
    end

#################  AFTER SAVE CALLBACKS

    def decrement_campaign_item_reserve
        payable.reserve -= 1
        payable.save
    end

    def update_campaign_expire_date
        if expires_at.to_date > giver.expire_date
            giver.update(expire_date: expires_at.to_date)
        end
    end

#################  VALIDATIONS

    def is_giftable
        unless giver.is_live?
            text = payable.status_text
            errors.add(:campaign, "#{text}. No gifts can be created.")
        end
        unless payable.has_reserve?
            errors.add(:campaign_item, "reserve is empty. No more gifts can be created under this campaign item.")
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

