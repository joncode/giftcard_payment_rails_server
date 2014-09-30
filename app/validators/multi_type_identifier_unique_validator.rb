class MultiTypeIdentifierUniqueValidator < ActiveModel::Validator

	def validate(record)
		if record.active
			record_type = record.type_of
			UserSocial.where(identifier: record.identifier.to_s).each do |us|
				if us.type_of == record_type && us.id != record.id
					puts "not passing user social validations because #{us.inspect} == #{record.inspect}"
					return record.errors[record_type.to_sym] << "is already in use. Please email support@itson.me for assistance if this is in error"
				end
			end
		end
	end
end
