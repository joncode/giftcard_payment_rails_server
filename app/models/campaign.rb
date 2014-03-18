class Campaign < Admtmodel
    self.table_name = "campaigns"

    #has_many :gifts, :as => :payable
    has_many :campaign_items

    def is_live?
        self.live_date < today && self.close_date > today
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

private

    def today
        Time.now.to_date
    end
end


