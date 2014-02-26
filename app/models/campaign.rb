class Campaign < Admtmodel
    self.table_name = "campaigns"
    # has_many :sent,  as: :giver,  class_name: Gift
    # has_many :debts, as: :owner


    #       ####### Gift Giver Ducktype
    # def name
    #     # giver_name attribute in campaign db
    #     self.giver_name
    # end

    # def get_photo
    #     # wrapped photo attribute in campaign db
    #     self.giver_photo
    # end


    # # hidden giver ducktype methods
    #     # campaign_giver.id    as giver_id   - campaign_id in ADMT
    #     # campaign_giver.class as giver_type - Campaign class
    has_many :gifts, :as => :payable
    has_many :campaigns_items

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
# == Schema Information
#
# Table name: campaigns
#
#  id          :integer         not null, primary key
#  campaign_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

