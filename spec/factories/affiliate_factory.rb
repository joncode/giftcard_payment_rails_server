module AffiliateFactory

	def make_affiliate(first, last)
		FactoryGirl.create(:affiliate,
			first_name: first.capitalize,
			last_name: last.capitalize,
			email: "#{first}@#{last}.com".downcase,
			url_name: "#{first}_#{last}".downcase)
	end

	def make_partner_client(first, last)
		a = make_affiliate(first,last)
		FactoryGirl.create(:client, partner_id: a.id, partner_type: a.class.to_s)
	end

end