class UserFirstNameValidator < ActiveModel::Validator

    def validate(record)
        if record.first_name_changed?
            validator_method(record, "first_name")
        end
    end

private

    def validator_method(record, attribute)
        if record.first_name == "(null)"
            return record.errors[attribute.to_sym] << "Account creation was not successful. Please go back one screen, re-enter your first name and re-submit. Thanks."
        end
    end
end