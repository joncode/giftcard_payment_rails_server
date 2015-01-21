require 'spec_helper'

include AffiliateFactory
include UserFactory
include MerchantFactory
include GiftModelFactory

describe "Affiliate Life Feature" do

	it "should calculate all values for affiliate" do
			# make few affiliates
		a1 = make_affiliate("test", "one")
		a2 = make_affiliate("nbumberEstaban", "twoGenerates")
		a3 = make_affiliate("rando", "third")
			# make a few merchants
		m1 = make_merchant_provider("thirstys")
		m2 = make_merchant_provider("sushiOne")
		m3 = make_merchant_provider("Taco nachos forever")
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
		p_not = FactoryGirl.create(:provider)
		g1 = make_gift_sale(u3, u2, "100", p_not.id)
		g2 = make_gift_sale(u1, u2, "200", m1.provider.id)
		g3 = make_gift_sale(u2, u_not, "300",  m2.provider.id)
		g4 = make_gift_sale(u2, u2, "400",  m3.provider.id)
		g5 = make_gift_sale(u_not, u3, "500",  m1.provider.id)
		g6 = make_gift_sale(u_not, u1, "600",  m2.provider.id)
			# REWARDS
		# a1 					   = 3$ (g2) + 7.5$ (g5)
		a1.reload
		a1.total_merchants.should  == 1
		a1.payout_merchants.should == 1050
		# a2                       = 4.5$ (g3) + 6$ (g4)
		a2.reload
		a2.total_users.should      == 1
		a2.payout_users.should     == 1050
		# a3                       = 1.5$ (g1/u3) + 6$ (g4/m3)
		a3.reload
		a1.total_merchants.should  == 1
		a1.payout_merchants.should == 600
		a2.total_users.should      == 1
		a2.payout_users.should     == 150

	# make a gift from aff user and aff merchant
		# TEST
		# debts are created correctly
		# check data for
			# reportings summary
			# reportings locations
			# reportings users

	# generate a payment for affiliate
		# TEST

		binding.pry
	end
end