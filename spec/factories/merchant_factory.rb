module MerchantFactory

	def make_merchant_provider(name)
		m = FactoryGirl.create(:merchant, name: name.titleize)
		m.creation!
		r = FactoryGirl.create(:region)
		m.update(city_id: r.id)
		m
	end

	def make_many_merchants(amount, root_name)
		ary_of_merchants = []
		r = FactoryGirl.create(:region)
		menu = FactoryGirl.create(:menu)
		amount.times do |index|
			name = "#{root_name}_#{index.to_s}"
			m = FactoryGirl.create(:merchant, name: name.titleize, city_id: r.id, menu_id: menu.id)
			m.creation!
			ary_of_merchants << m
		end
		ary_of_merchants
	end

end