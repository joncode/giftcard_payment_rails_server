class UserSocialValidator < ActiveModel::Validator

    def validate(record)
        if record.email_changed?
            validator_method(record, "email")
        end

        if record.phone_changed?
            validator_method(record, "phone")
        end

        if record.twitter_changed?
            validator_method(record, "twitter")
        end

        if record.facebook_id_changed?
            validator_method(record, "facebook_id")
        end
    end

private

    def validator_method(record, attribute)
        valid = true
        if record.active
            UserSocial.where(active: true).each do |us|
                if us.type_of == attribute && us.identifier == record.send(attribute) && us.user_id != record.id
                    record.errors[attribute.to_sym] << "#{us.identifier} already has an account. Use that account or email support@itson.me for help."
                    valid = false
                    break
                end
            end
        end
        return valid
    end
end