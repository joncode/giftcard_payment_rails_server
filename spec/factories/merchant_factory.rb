module MerchantFactory

	def make_merchant_provider(name)
		m = FactoryGirl.create(:merchant, name: name.titleize)
		m.creation!
		r = FactoryGirl.create(:region)
		m.update(city_id:r.id)
		m
	end


end