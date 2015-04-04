require 'spec_helper'

include AffiliateFactory
include UserFactory
include MerchantFactory
include GiftModelFactory

describe "Gift To Payment" do

	it "should calculate merchant and affiliate payments" do
			# make few affiliates
		a1 = make_affiliate("test", "one")
		a2 = make_affiliate("nbumberEstaban", "twoGenerates")
		a3 = make_affiliate("rando", "third")
			# make a few merchants
		m1 = make_merchant_provider("thirstys")
		m2 = make_merchant_provider("sushiOne")
		m2.provider.update(rate: 95)
		m3 = make_merchant_provider("Taco nachos forever")
		m3.provider.update(rate: 96.1)
			# attach a merchant to test affiliate
		m1.affiliate = a1
		a1.merchants.first.should == m1
		m3.affiliate = a3
		a3.merchants.first.should == m3
			# make some users
		u1 = make_user("Tom", "Yorke")
		u2 = make_user("Jimmy", "Buffet")
		u3 = make_user("Armani", "Georgio")
			# attach a user to test affiliate
		u2.affiliate = a2
		a2.users.first.should == u2
		u3.affiliate = a3
		a3.users.first.should == u3
			# make a batch of gifts
		u_not = FactoryGirl.create(:user)
		m_not = make_merchant_provider("Not Merchant")
		p_not = m_not.provider


		ResqueSpec.reset!
		GiftSale.any_instance.stub(:messenger)
		g1 = make_gift_sale(u3, u2, "100", p_not.id)
		g2 = make_gift_sale(u1, u2, "200", m1.provider.id)
		g3 = make_gift_sale(u2, u_not, "300",  m2.provider.id)
		g4 = make_gift_sale(u2, u2, "400",  m3.provider.id)
		g5 = make_gift_sale(u_not, u3, "500",  m1.provider.id)
		g6 = make_gift_sale(u_not, u1, "600",  m2.provider.id)
		#binding.pry
		run_delayed_jobs
			# REWARDS
		# a1 					   = 3$ (g2) + 7.5$ (g5)
		a1.reload
		a1.total_merchants.should  == 1
		a1.payout_merchants.should == 1050
		a1.value_merchants.should  == 70000
		a1.purchase_merchants.should == 2
		# a2                       = 4.5$ (g3) + 6$ (g4)
		a2.reload
		a2.total_users.should      == 1
		a2.payout_users.should     == 1050
		a2.value_users.should  	   == 70000
		a2.purchase_users.should   == 2
		# a3                       = 1.5$ (g1/u3) + 6$ (g4/m3)
		a3.reload
		a3.total_merchants.should  == 1
		a3.payout_merchants.should == 600
		a3.value_merchants.should  == 40000
		a3.purchase_merchants.should == 1
		a3.total_users.should      == 1
		a3.payout_users.should     == 150
		a3.value_users.should  	   == 10000
		a3.purchase_users.should   == 1

		r1s = m1.registers
		r2s = m2.registers
		r3s = m3.registers
		r1s.count.should == 2
		r2s.count.should == 2
		r3s.count.should == 1
		r1s[0].amount.should == 17000
		r1s[1].amount.should == 42500
		r2s[0].amount.should == 28500
		r2s[1].amount.should == 57000
		r3s[0].amount.should == 38440
	end

	it "should generate payments on :redeem if :create payments are not created" do
			# make few affiliates
		a1 = make_affiliate("test", "one")
		a2 = make_affiliate("nbumberEstaban", "twoGenerates")
		a3 = make_affiliate("rando", "third")
			# make a few merchants
		m1 = make_merchant_provider("thirstys")
		m2 = make_merchant_provider("sushiOne")
		m2.provider.update(rate: 95)
		m3 = make_merchant_provider("Taco nachos forever")
		m3.provider.update(rate: 96.1)
			# attach a merchant to test affiliate
		m1.affiliate = a1
		a1.merchants.first.should == m1
		m3.affiliate = a3
		a3.merchants.first.should == m3
			# make some users
		u1 = make_user("Tom", "Yorke")
		u2 = make_user("Jimmy", "Buffet")
		u3 = make_user("Armani", "Georgio")
			# attach a user to test affiliate
		u2.affiliate = a2
		a2.users.first.should == u2
		u3.affiliate = a3
		a3.users.first.should == u3
			# make a batch of gifts
		u_not = FactoryGirl.create(:user)
		m_not = make_merchant_provider("Not Merchant")
		p_not = m_not.provider


		ResqueSpec.reset!
		GiftSale.any_instance.stub(:messenger)
		GiftSale.any_instance.stub(:messenger_publish_gift_created)
		g1 = make_gift_sale(u3, u2, "100", p_not.id)
		g2 = make_gift_sale(u1, u2, "200", m1.provider.id)
		g3 = make_gift_sale(u2, u_not, "300",  m2.provider.id)
		g4 = make_gift_sale(u2, u2, "400",  m3.provider.id)
		g5 = make_gift_sale(u_not, u3, "500",  m1.provider.id)
		g6 = make_gift_sale(u_not, u1, "600",  m2.provider.id)
		#binding.pry
		run_delayed_jobs

		[g1,g2,g3,g4,g5,g6].each {|g| g.notify; g.redeem_gift; }
			# REWARDS
		run_delayed_jobs
		r1s = m1.registers
		r2s = m2.registers
		r3s = m3.registers
		r1s.count.should == 2
		r2s.count.should == 2
		r3s.count.should == 1

		r1s[0].amount.should == 17000
		r1s[1].amount.should == 42500
		r2s[0].amount.should == 28500
		r2s[1].amount.should == 57000
		r3s[0].amount.should == 38440
	end

	it "should NOT double generate payments" do
			# make few affiliates
		a1 = make_affiliate("test", "one")
		a2 = make_affiliate("nbumberEstaban", "twoGenerates")
		a3 = make_affiliate("rando", "third")
			# make a few merchants
		m1 = make_merchant_provider("thirstys")
		m2 = make_merchant_provider("sushiOne")
		m2.provider.update(rate: 95)
		m3 = make_merchant_provider("Taco nachos forever")
		m3.provider.update(rate: 96.1)
			# attach a merchant to test affiliate
		m1.affiliate = a1
		a1.merchants.first.should == m1
		m3.affiliate = a3
		a3.merchants.first.should == m3
			# make some users
		u1 = make_user("Tom", "Yorke")
		u2 = make_user("Jimmy", "Buffet")
		u3 = make_user("Armani", "Georgio")
			# attach a user to test affiliate
		u2.affiliate = a2
		a2.users.first.should == u2
		u3.affiliate = a3
		a3.users.first.should == u3
			# make a batch of gifts
		u_not = FactoryGirl.create(:user)
		m_not = make_merchant_provider("Not Merchant")
		p_not = m_not.provider


		ResqueSpec.reset!
		GiftSale.any_instance.stub(:messenger)
		g1 = make_gift_sale(u3, u2, "100", p_not.id)
		g2 = make_gift_sale(u1, u2, "200", m1.provider.id)
		g3 = make_gift_sale(u2, u_not, "300",  m2.provider.id)
		g4 = make_gift_sale(u2, u2, "400",  m3.provider.id)
		g5 = make_gift_sale(u_not, u3, "500",  m1.provider.id)
		g6 = make_gift_sale(u_not, u1, "600",  m2.provider.id)
		#binding.pry
		run_delayed_jobs

		[g1,g2,g3,g4,g5,g6].each {|g| g.notify; g.redeem_gift; }
			# REWARDS
		run_delayed_jobs
		r1s = m1.registers
		r2s = m2.registers
		r3s = m3.registers
		r1s.count.should == 2
		r2s.count.should == 2
		r3s.count.should == 1

		r1s[0].amount.should == 17000
		r1s[1].amount.should == 42500
		r2s[0].amount.should == 28500
		r2s[1].amount.should == 57000
		r3s[0].amount.should == 38440

	end

	it "should generate payment on redemption that payment_event" do
			# make few affiliates
		a1 = make_affiliate("test", "one")
		a2 = make_affiliate("nbumberEstaban", "twoGenerates")
		a3 = make_affiliate("rando", "third")
			# make a few merchants
		m1 = make_merchant_provider("thirstys")
		m1.provider.redemption!
		m2 = make_merchant_provider("sushiOne")
		m2.provider.redemption!
		m2.provider.update(rate: 95)
		m3 = make_merchant_provider("Taco nachos forever")
		m3.provider.redemption!
		m3.provider.update(rate: 96.1)
			# attach a merchant to test affiliate
		m1.affiliate = a1
		a1.merchants.first.should == m1
		m3.affiliate = a3
		a3.merchants.first.should == m3
			# make some users
		u1 = make_user("Tom", "Yorke")
		u2 = make_user("Jimmy", "Buffet")
		u3 = make_user("Armani", "Georgio")
			# attach a user to test affiliate
		u2.affiliate = a2
		a2.users.first.should == u2
		u3.affiliate = a3
		a3.users.first.should == u3
			# make a batch of gifts
		u_not = FactoryGirl.create(:user)
		m_not = make_merchant_provider("Not Merchant")
		p_not = m_not.provider


		ResqueSpec.reset!
		GiftSale.any_instance.stub(:messenger)
		g1 = make_gift_sale(u3, u2, "100", p_not.id)
		g2 = make_gift_sale(u1, u2, "200", m1.provider.id)
		g3 = make_gift_sale(u2, u_not, "300",  m2.provider.id)
		g4 = make_gift_sale(u2, u2, "400",  m3.provider.id)
		g5 = make_gift_sale(u_not, u3, "500",  m1.provider.id)
		g6 = make_gift_sale(u_not, u1, "600",  m2.provider.id)
		#binding.pry
		run_delayed_jobs

		m1.registers.count.should == 0
		m2.registers.count.should == 0
		m3.registers.count.should == 0

		[g1,g2,g3,g4,g5,g6].each {|g| g.notify; g.redeem_gift; }
			# REWARDS
		run_delayed_jobs
		r1s = m1.registers
		r2s = m2.registers
		r3s = m3.registers
		r1s.count.should == 2
		r2s.count.should == 2
		r3s.count.should == 1

		r1s[0].amount.should == 17000
		r1s[1].amount.should == 42500
		r2s[0].amount.should == 28500
		r2s[1].amount.should == 57000
		r3s[0].amount.should == 38440

	end
end