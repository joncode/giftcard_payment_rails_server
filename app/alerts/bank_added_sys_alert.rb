class BankAddedSysAlert < Alert


	def bank_ary
		self.target || []
	end

#   -------------

	def text_msg
		get_data
		"#{name_string}\n#{@data}"
	end

	def email_msg
		get_data
		"<div><h2>#{name_string}</h2><p>#{@data}</p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		@data = ''
		bank_ary.each do |bank|
			@data += "Bank Account created for #{bank.owner.name} #{bank.owner.id}\n"
		end
		@data
	end

end


