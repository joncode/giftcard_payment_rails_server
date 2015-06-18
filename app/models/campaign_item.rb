class CampaignItem < ActiveRecord::Base

    has_many :gifts, as: :payable
    belongs_to :campaign
    belongs_to :provider

#   -------------

    def has_reserve?
        self.reserve > 0
    end

    def item_is_live?
        if self.expires_at && self.expires_at < Time.now.to_date
            false
        else
            true
        end
    end

    def live?
        has_reserve? && campaign.is_live? && item_is_live?
    end

    def status_text
        str = "#{campaign.cname} - textword (#{self.textword}) "
        return (str + "is live")             if live?
        return (str + "reserve is empty")    if !has_reserve?
        return (str + "has not started yet") if campaign.is_new?
        return (str + "is closed")           if campaign.is_closed?
    end

    def owner
       campaign
    end

    def name
        "#{self.id} - #{self.textword}"
    end

end
# == Schema Information
#
# Table name: campaign_items
#
#  id           :integer         not null, primary key
#  campaign_id  :integer
#  provider_id  :integer
#  giver_id     :integer
#  giver_name   :string(255)
#  budget       :integer
#  reserve      :integer
#  message      :text
#  shoppingCart :text
#  value        :string(255)
#  cost         :string(255)
#  expires_at   :date
#  expires_in   :integer
#  textword     :string(255)
#  contract     :boolean
#  created_at   :datetime
#  updated_at   :datetime
#  detail       :text
#

