class UniqueIdMaker


	class << self

		def eight_digit_hex klass, column_name
			klass = klass.to_s.titleize.constantize unless klass.kind_of?(Class)
			column_name = column_name.to_sym
	        unique_hex = SecureRandom.hex(4)
	        until klass.unscoped.where(column_name => unique_hex).count == 0
	            unique_hex = SecureRandom.hex(4)
	        end
	        return unique_hex
		end

		def four_digit_token klass, column_name, where_clause
			klass = klass.to_s.titleize.constantize unless klass.kind_of?(Class)
			column_name = column_name.to_sym
	        unique_value = rand(9000) + 1000
	        until klass.unscoped.where(column_name => unique_value).where(where_clause).count == 0
	            unique_value = rand(9000) + 1000
	        end
	        return unique_value
		end
	end


end