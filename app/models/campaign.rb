class Campaign < Admtmodel
    self.table_name = "campaigns"
    # has_many :sent,  as: :giver,  class_name: Gift
    # has_many :debts, as: :owner

    def status
        if self.is_new?
            "new"
        elsif self.is_live?
            "live"
        elsif self.is_closed?
            "closed"
        elsif self.is_expired?
            "expired"
        end
    end

    #       ####### Gift Giver Ducktype
    def name
        # giver_name attribute in campaign db
        self.giver_name
    end

    def get_photo
        if self.photo_path.present?
            self.photo_path 
        else
            "http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
        end
    end

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


    def is_new?
        today = Time.now.to_date
        if self.live_date.present? && self.live_date > today &&
           self.close_date.present? && self.close_date > today
            true
        else
            false
        end 
    end

    def is_live?
        today = Time.now.to_date
        if self.live_date.present?  && self.live_date  <= today &&
           self.close_date.present? && self.close_date >  today
            true
        else
            false
        end 
    end

    def is_closed?
        today = Time.now.to_date
        if self.close_date.present?  && self.close_date  <= today &&
           self.expire_date.present? && self.expire_date >  today
            true
        else
            false
        end 
    end

    def is_expired?
        today = Time.now.to_date
        if self.expire_date.present? && self.expire_date <= today
            true
        else
            false
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

