class Campaign < ActiveRecord::Base
    include Formatter
    self.table_name = "campaigns"

    has_many :campaign_items

    def status
        if is_expired?
            "expired"
        elsif is_closed?
            "closed"
        elsif is_new?
            "new"
        elsif is_live?
            "live"
        end
    end

    def is_new?
        live_date.present? && live_date > today
    end

    def is_live?
        live_date.present?  && live_date  <= today && close_date.present? && close_date > today
    end

    def is_closed?
        close_date.present?  && close_date  <= today
    end

    def is_expired?
        expire_date.present? && expire_date <= today
    end

    def gift_cat
        case self.purchaser_type
        when "AdminGiver"; 150
        when "BizUser"; 250
        end
    end

####### Gift Giver Ducktype

    def name
        self.giver_name
    end

    def cname
        self.read_attribute(:name)
    end

    def get_photo
        if self.photo_path.present?
            self.photo_path
        else
            "http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
        end
    end

    def short_image_url
        shorten_photo_url self.get_photo
    end

private

    def today
        Time.now.utc.to_date
    end
end


