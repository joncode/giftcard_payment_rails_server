class GiftReceiverInfoValidator < ActiveModel::Validator

    def validate(record)
        unique_ids = 0
        [:receiver_id, :receiver_phone, :receiver_email, :twitter, :facebook_id].each do |unique|
            unless record.send(unique).blank?
                unique_ids += 1
            end
        end
        if unique_ids == 0
            return record.errors[:receiver] << "No unique receiver data. Cannot process gift. Please re-log in if this is an error."
        end
    end

end


