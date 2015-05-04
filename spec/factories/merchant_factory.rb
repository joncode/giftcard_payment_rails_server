module MerchantFactory

	def make_merchant_provider(name)
		m = FactoryGirl.create(:merchant, name: name.titleize)
		p = FactoryGirl.create(:provider, name: m.name, address: m.address, merchant_id: m.id)
		p.creation!
		m
	end


end