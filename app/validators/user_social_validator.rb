class UserSocialValidator < ActiveModel::Validator

    def validate(record)
        resp = true
        if resp && record.email_changed?
            resp = validator_method(record, "email")
        end

        if resp && record.phone_changed?
            resp = validator_method(record, "phone")
        end

        if resp && record.twitter_changed?
            resp = validator_method(record, "twitter")
        end

        if resp && record.facebook_id_changed?
            resp = validator_method(record, "facebook_id")
        end
        return resp
    end

private

    def validator_method(record, attribute)
        valid = true
        if record.active
            UserSocial.where(active: true).each do |us|
                if (us.type_of == attribute) && (us.identifier == record.send(attribute)) && (us.user_id != record.id)
                    record.errors[attribute.to_sym] << "#{us.identifier} already has an account. Use that account or email support@itson.me for help."
                    valid = false
                end
                break if !valid
            end
        end
        return valid
    end
end