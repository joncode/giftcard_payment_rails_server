class Campaign < Admtmodel
    self.table_name = "campaigns"

    #has_many :gifts, :as => :payable
    has_many :campaign_items

    def is_live?
        self.live_date < today && self.close_date > today
    end

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

<<<<<<< HEAD

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

=======
private

    def today
        Time.now.to_date
    end
>>>>>>> jg
end


