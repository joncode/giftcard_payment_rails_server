class CampaignItem < Admtmodel
    self.table_name = "campaign_items"

    include GenericPayableDucktype

    has_many :gifts, as: :payable
    belongs_to :campaign
    belongs_to :provider

    def has_reserve?
        self.reserve > 0
    end

    def live?
        has_reserve? && campaign.is_live?
    end

    def status_text
        str = "#{campaign.name} #{self.textword} "
        return (str + "is live")             if live?
        return (str + "reserve is empty")    if !has_reserve?
        return (str + "has not started yet") if campaign.is_new?
        return (str + "is closed")           if campaign.is_closed?
    end

    def owner
       campaign
    end
end
