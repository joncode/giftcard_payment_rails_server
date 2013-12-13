class TypeIdValidator < ActiveModel::Validator

	def validate(record)
		record_type = record.type_of
		unless UserSocial.count == 1
			UserSocial.where(active:true).to_a.each do |us|
				if us.type_of == record_type && us.identifier == record.identifier 
					return record.errors[record_type.to_sym] << "is already in use. Please email support@itson.me for assistance if this is in error"
				end
			end
		end
	end
end
