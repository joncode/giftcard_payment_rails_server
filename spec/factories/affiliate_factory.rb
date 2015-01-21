module AffiliateFactory

	def make_affiliate(first, last)
		FactoryGirl.create(:affiliate,
			first_name: first.capitalize,
			last_name: last.capitalize,
			email: "#{first}@#{last}.com".downcase,
			url_name: "#{first}_#{last}".downcase)
	end



end