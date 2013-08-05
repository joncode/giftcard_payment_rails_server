module JsonHelper


    def unauthorized_user
        { "Failed Authentication" => "Please log out and re-log into app" }
    end

    def database_error_redeem
        { "Data Transfer Error"   => "Please Reload Gift Center" }
    end

    def database_error_gift
        { "Data Transfer Error"   => "Please Retry Sending Gift" }
    end

    def database_error_general
        { "Data Transfer Error"   => "Please Reset App" }
    end

    def authentication_data_error
        { "Data Transfer Error"   => "Authentication Failed" }
    end

    def database_error
        { "Server Error"          => "Database Error" }
    end

    def stringify_error_messages object
        msgs = object.errors.messages
        msgs.stringify_keys!
        msgs.each_key do |key|
            value_as_ary    = msgs[key]
            if value_as_array.kind_of? Array
                value_as_string = value_as_ary.join(' | ')
            else
                value_as_string = value_as_ary
            end
            msgs[key]       = value_as_string
        end
        msgs
    end

    def extract_phone_digits phone_raw
        if phone_raw
            phone_match = phone_raw.match(VALID_PHONE_REGEX)
            phone       = phone_match[1] + phone_match[2] + phone_match[3]
        end
    end
end
