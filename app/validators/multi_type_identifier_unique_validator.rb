class MultiTypeIdentifierUniqueValidator < ActiveModel::Validator

	def validate(record)
		if record.active
			record_type = record.type_of
			UserSocial.where(active: true).each do |us|
				if us.type_of == record_type && us.identifier == record.identifier
					return record.errors[record_type.to_sym] << "is already in use. Please email support@itson.me for assistance if this is in error"
				end
			end
		end
	end
end
