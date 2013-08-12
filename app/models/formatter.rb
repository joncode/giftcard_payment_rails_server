module Formatter

    def extract_phone_digits
        if phone_exists?
            phone_match = self.phone.match(VALID_PHONE_REGEX)
            self.phone  = phone_match[1] + phone_match[2] + phone_match[3]
        end
    end

    def phone_exists?
        !self.phone.blank? && self.phone.length > 9
    end

    def format_currency_as_string(float)
        string = float.to_s
        x      = string.split('.')
        x[1]   = "%02d" % x[1].to_i
        x[1]   = x[1][0..1]
        x[1]   = x[1].to_s
        total  = x.join('.')
        return total
    end

    def remove_key_from_hash(obj_hash, key_for_removal)
        if obj_hash.has_key? key_for_removal
            obj_hash.delete(key_for_removal)
        end
    end

    def full_address
        "#{self.address},  #{self.city}, #{self.state}"
    end

    def complete_address
        "#{self.address}, #{self.city_state_zip}"
    end

    def city_state_zip
        "#{self.city}, #{self.state} #{self.zip}"
    end

end