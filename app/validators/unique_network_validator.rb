class UniqueNetworkValidator < ActiveModel::Validator

    def validate(record)
        ac = AppContact.where(network: record.network, network_id: record.network_id).first

        if ac.present?
            return record.errors[:contact] << "already exists."
        end

    end
end