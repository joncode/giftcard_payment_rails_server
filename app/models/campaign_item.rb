class CampaignItem < Admtmodel
    self.table_name = "campaign_items"

    has_many :gifts, as: :payable
    belongs_to :owner, polymorphic: :true

    def amount
    	self.cost
    end

end
