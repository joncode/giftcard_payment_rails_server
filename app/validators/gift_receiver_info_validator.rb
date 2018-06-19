class GiftReceiverInfoValidator < ActiveModel::Validator

    def validate(record)
        network_ids = 0
        [:receiver_id, :receiver_phone, :receiver_email, :twitter, :facebook_id].each do |network_id|
            unless record.send(network_id).blank?
                network_ids += 1
            end
        end
        if network_ids == 0 && record.rec_net.to_s != 'hd'
            return record.errors[:receiver] << "No network_id receiver data. Cannot process gift. Please re-log in if this is an error."
        end
    end

end
