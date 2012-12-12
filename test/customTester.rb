class CustomTester

	load 'test/redeem_rec.rb'
	load 'test/buy_giver.rb'
	load 'test/gift_model_tests.rb'

    g = GiftTests.new
	b = BuyTests.new
	b.all

	r = RedeemTests.new
	r.all
	
    


end
