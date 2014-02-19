class Campaign < Admtmodel
    self.table_name = "campaigns"
    has_many :sent,  as: :giver,  class_name: Gift
    has_many :debts, as: :owner


          ####### Gift Giver Ducktype
    def name
        # giver_name attribute in campaign db
        self.giver_name
    end

    def get_photo
        # wrapped photo attribute in campaign db
        self.giver_photo
    end


    # hidden giver ducktype methods
        # campaign_giver.id    as giver_id   - campaign_id in ADMT
        # campaign_giver.class as giver_type - Campaign class



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

