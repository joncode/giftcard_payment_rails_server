class UniqueIdMaker


	class << self

		def secure_url_safe klass, column_name, prefix='', length=44
			klass = klass.to_s.titleize.constantize unless klass.kind_of?(Class)
			column_name = column_name.to_sym
			length = length - prefix.length
	        unique_key = prefix + rando_safe(length)
	        until klass.unscoped.where(column_name => unique_key).count == 0
	            unique_key = prefix + rando_safe(length)
	        end
	        return unique_key
		end

		def rando_safe len=44
			str = SecureRandom.urlsafe_base64(len + 10, false).gsub('-','').gsub('_','')
			str[0...len]
		end

		def eight_digit_hex klass, column_name, prefix=''
			klass = klass.to_s.titleize.constantize unless klass.kind_of?(Class)
			column_name = column_name.to_sym
	        unique_hex = prefix + SecureRandom.hex(4)
	        until klass.unscoped.where(column_name => unique_hex).count == 0
	            unique_hex = prefix + SecureRandom.hex(4)
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