require 'spec_helper'

# include MocksAndStubs
include AffiliateFactory
include UserFactory
include MerchantFactory
include GiftModelFactory

describe AccountsPayableCronJob do

    describe :perform do

    	it "should gifts to the payment except when 'settled' or 'deactivated'" do
				# make few affiliates
			a1 = make_affiliate("test", "one")
			a2 = make_affiliate("nbumberEstaban", "twoGenerates")
			a3 = make_affiliate("rando", "third")
				# make a few merchants
			m1 = make_merchant_provider("thirstys")
			m2 = make_merchant_provider("sushiOne")
			m2.update(rate: 95)
			m3 = make_merchant_provider("Taco nachos forever")
			m3.update(rate: 96.1)
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
			p_not = m_not

			ResqueSpec.reset!
			GiftSale.any_instance.stub(:messenger)
			g1 = make_gift_sale(u3, u2, "100", p_not.id)
			g2 = make_gift_sale(u1, u2, "200", m1.id)
			g3 = make_gift_sale(u2, u_not, "300",  m2.id)
			g4 = make_gift_sale(u2, u2, "400",  m3.id)
			g5 = make_gift_sale(u_not, u3, "500",  m1.id)
			g6 = make_gift_sale(u_not, u1, "600",  m2.id)

				# do not include settled gifts
			g7 = make_gift_sale(u_not, u_not, "100", p_not.id)
			g8 = make_gift_sale(u_not, u_not, "100", p_not.id)


			run_delayed_jobs

			gs = Gift.all
			date = DateTime.now - 1.weeks
			gs.each do |gift|
				rs = gift.registers
				rs.each do |reg|
					reg.update(created_at: date)
				end

			end

			g7.update(pay_stat: 'settled')
			g8.update(active: false)
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

			# r1s[0].amount.should == 17000
			# r1s[1].amount.should == 42500
			# r2s[0].amount.should == 28500
			# r2s[1].amount.should == 57000
			# r3s[0].amount.should == 38440

			date = DateTime.now - 1.weeks

			AccountsPayableCronJob.perform date
			ps = Payment.all
			ps.count.should == 7

			settled_gift_payment = p_not.payments.first
			settled_gift_payment.total.should == 8500

		end


    end

end