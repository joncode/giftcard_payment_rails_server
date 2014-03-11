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
        if record.active
            UserSocial.where(active: true).each do |us|
                if us.type_of == attribute && us.identifier == record.send(attribute) && us.user_id != record.id
                    return record.errors[attribute.to_sym] << "is already in use. Please email support@itson.me for assistance if this is in error"
                end
            end
        end
    end
end