module Formatters
    extend ActiveSupport::Concern

########      CONTACT / DETAILS

    def make_name(data_hash)
        if data_hash["last_name"].present?
            data_hash["first_name"] + " " + data_hash["last_name"]
        else
            data_hash["first_name"] || data_hash['email'] || 'User'
        end
    end

    def make_url_string str
        if str.kind_of?(String)
            str = make_slug(str).tr('-','_')
        end
        str
    end

    def make_slug str
        if str.kind_of?(String)
            str = str.gsub("'", '').gsub(',', '').gsub('.', '').gsub("`", '').gsub(';', '').gsub('&', 'and').gsub('@', 'at').parameterize
        end
        str
    end

    def extract_phone_digits
        extract_digits self.phone
    end

    def extract_digits phone_str
        if phone_exists?(phone_str)
            phone_match = phone_str.match(VALID_PHONE_REGEX)
            if phone_match.present?
                phone_str  = phone_match[1] + phone_match[2] + phone_match[3]
            end
        end
    end

    def full_address
        "#{self.address}, #{self.city}, #{self.state}"
    end

    def html_complete_address
        "#{self.address}<br />#{self.city}, #{self.state} #{self.zip}".html_safe
    end

private

    def facebook_id_exists?
        self.facebook_id != nil
    end

    def twitter_exists?
        self.twitter != nil
    end

    def phone_exists? phone_str=nil
        if phone_str.nil?
            phone_str = self.phone
        end
        !phone_str.blank? && phone_str.length > 9
    end

end
