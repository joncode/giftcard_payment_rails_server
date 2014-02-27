class CampaignItem < Admtmodel
    self.table_name = "campaign_items"

    has_many :gifts, as: :payable
    belongs_to :campaign
    belongs_to :provider

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
end
