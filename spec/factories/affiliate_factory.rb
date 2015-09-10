module AffiliateFactory

	def make_affiliate(first, last)
		FactoryGirl.create(:affiliate,
			first_name: first.capitalize,
			last_name: last.capitalize,
			email: "#{first}.#{last}@#{first}#{last}.com".downcase,
			url_name: "#{first}_#{last}".downcase,
			website_url: "#{first}.#{last}.com",
			company: "#{first.capitalize} #{last.capitalize}"
		)
	end

	def make_partner_client(first, last)
		a = make_affiliate(first,last)
		FactoryGirl.create(:client, partner_id: a.id, partner_type: a.class.to_s)
	end

	def make_client_for_partner(partner, ecosystem=:partner, platform=:ios)
		FactoryGirl.create(:client,
			partner_id: partner.id,
			partner_type: partner.class.to_s,
			url_name: "#{partner.url_name}_client",
			name: "#{partner.company} Client",
			detail: "The #{platform.to_s} client for #{partner.company}. Please email #{partner.email} for support.",
			ecosystem: ecosystem,
			platform: platform
		)
	end

end