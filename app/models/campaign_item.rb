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
        return (str + "is finished")         if (today > campaign.close_date)
    end

    def owner
    	self.campaign
    end

    def success?
        if self.id
            true
        else
            false
        end
    end

    def resp_code
        if self.id
            1
        else
            3
        end
    end

    def reason_text
        if self.id
            "Transaction approved."
        else
            self.errors.full_messages
        end
    end

    def reason_code
        if self.id
            1
        else
            2
        end
    end

private

    def today
        Time.now.to_date
    end
end
