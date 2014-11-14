module UpdateUserMeta
    extend ActiveSupport::Concern

	def update args
		# strings the keys
		args = args.stringify_keys

		# makes sure the values for faceboob_id & twitter are strings
		us_ary = ["email", "phone", "facebook_id", "twitter"]

		# delete the promary kay and save it in a var
		primary = args.delete("primary")

		# if those user social keys exist
		type_ofs = us_ary.select { |us|  args.has_key? us }
		if type_ofs.count > 0
			us_ary.each do |network|
				if args[network]
					args[network] = args[network].to_s
				end
			end
			# these are the old values on the user = reload args
			original_user_args = set_type_ofs type_ofs, args

			puts "\nuser.update - here is the args #{args.inspect}"

			# confirm that user is valid after updating just the socials
			if self.valid?
				if primary
					# finds or creates the user socials and returns an array
					init_user_socials(type_ofs, args)
				else
					set_type_ofs type_ofs, original_user_args
					set_user_socials type_ofs, args
					puts "user.update valid - #{args.inspect}"
					args.except!("email", "phone", "facebook_id", "twitter")
				end
			else
				puts "user.update errors - #{self.errors}"
				self.errors
			end
		end
		super
	end

	def init_user_socials type_ofs, args
		# loop thru social keys
		ary_of_valids = type_ofs.map do |type_of|
			puts "\n ----  set_type_ofs #{type_of} ------- \n"
			us = UserSocial.new(type_of: type_of.to_s, identifier: args[type_of], user_id: self.id, active: true)
		    puts "\n social init_user_socials event - #{us.inspect}\n"
			us
		end
		# return as array of user socials
	end

	def set_user_socials type_ofs, args
		type_ofs.each do |type_of|
			unless user_social = UserSocial.find_or_create_by(type_of: type_of.to_s, identifier: args[type_of], user_id: self.id)
				puts "set_user_socials  - #{user_social.errors}"
				# what does this do vv ?
				user_social.errors
				if us.errors.messages.keys.count > 0
					puts "here are the errors - #{us.errors.inspect}"
				end
			end
		end
	end

	def set_type_ofs type_ofs, args
		old_args = {}
		type_ofs.each do |type_of|
			puts "\n ----  set_type_ofs #{type_of} ------- \n"
			old_args[type_of] = self.send("#{type_of}")
			self.send("#{type_of}=", args[type_of])
		end
		old_args
	end

end