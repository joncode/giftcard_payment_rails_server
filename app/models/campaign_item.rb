class CampaignItem < Admtmodel
    self.table_name = "campaign_items"

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
        return (str + "has not started yet") if (today < campaign.live_date)
        return (str + "is closed")           if (today >= campaign.close_date)
    end

    def owner
    	campaign
    end

    def success?
        self.id.present?
    end

    def resp_code
        self.id ? 1 : 3
    end

    def reason_text
        if self.id
            "Transaction approved."
        else
            self.errors.full_messages
        end
    end

    def reason_code
        self.id ? 1 : 2
    end

private

    def today
        Time.now.utc.to_date
    end
end
