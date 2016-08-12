class MultiTypeIdentifierUniqueValidator < ActiveModel::Validator

	def validate(record)
		if record.active
			record_type = record.type_of
			UserSocial.where(identifier: record.identifier.to_s).each do |us|
				if us.type_of == record_type && us.id != record.id
					puts "not passing user social validations because #{us.inspect} == #{record.inspect}"
					return record.errors[record_type.to_sym] << "#{record.identifier} already has an account. Use that account or email support@itson.me for help."
				end
			end
		end
	end
end
