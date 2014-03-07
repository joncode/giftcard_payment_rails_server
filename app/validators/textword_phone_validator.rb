class TextwordPhoneValidator < ActiveModel::Validator

    def validate(record)

        found = SmsContact.where(textword: record.textword, phone: record.phone)
        if found.count > 0
            return record.errors["textword"] << "already has saved this phone number. "
        end

    end

end