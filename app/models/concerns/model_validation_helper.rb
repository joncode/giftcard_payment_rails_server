module ModelValidationHelper
    extend ActiveSupport::Concern

    def extract_phone_digits phone_raw
        if phone_raw.blank?
            phone_match = phone_raw.match(VALID_PHONE_REGEX)
            phone_match[1] + phone_match[2] + phone_match[3]
        end
    end

    def strip_and_downcase email_raw
        if email_raw.kind_of?(String)
            email_raw.downcase.strip
        else
        	email_raw
        end
    end

private

    def is_email?
        self.network == 'email'
    end

    def is_phone?
        self.network == 'phone'
    end

end