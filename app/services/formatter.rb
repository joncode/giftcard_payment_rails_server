module Formatter
    include ActionView::Helpers::NumberHelper

    def extract_phone_digits
        if phone_exists?
            phone_match = self.phone.to_s.match(VALID_PHONE_REGEX)
            self.phone  = phone_match[1] + phone_match[2] + phone_match[3]
        end
    end

    def phone_exists?
        !self.phone.blank? && self.phone.to_s.length > 9
    end

    def format_datetime datetime
        datetime and datetime.to_formatted_s :merchant_date
    end

    def format_date datetime
        datetime and datetime.to_formatted_s :only_date
    end

    def full_address
        "#{self.address},  #{self.city}, #{self.state}"
    end

    def complete_address
        "#{self.address}, #{self.city_state_zip}"
    end

    def street_address
        x = "#{self.address} #{self.address_2}"
        x.strip
    end

    def city_state_zip
        "#{self.city}, #{self.state} #{self.zip}"
    end

    def html_complete_address
        "#{self.address}<br />#{self.city}, #{self.state} #{self.zip}".html_safe
    end

    def remove_nils(hsh)
        hsh.delete_if { |k, v| v.nil? }
    end

    def remove_key_from_hash obj_hash, key_for_removal
        if obj_hash.has_key? key_for_removal
            obj_hash.delete(key_for_removal)
        end
    end

    def split_name name
        name_ary    = name.split(' ')
        last_name   = name_ary.last
        first_name  = if name_ary.kind_of? String
            name_ary
        else
            name_ary.join(' ')
        end
        return first_name, last_name
    end

end