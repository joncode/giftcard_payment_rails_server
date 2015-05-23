require 'spec_helper'

include MerchantFactory
include GiftModelFactory

describe Accountant do

	let(:m1) { make_merchant_provider("thirstys")  }
	let(:u) { FactoryGirl.create(:user) }

	describe "merchant" do

		it "should require a gift" do
			g    ="Not a gift"
			resp = Accountant.merchant(g)
			resp.should  == "Not Gift"
		end

		it "should create debt 85% in register for the merchant" do
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 300)
			resp = Accountant.merchant(g)
			reg  = Register.last
			reg.gift_id.should      == g.id
			reg.origin.should       == "loc"
			reg.amount.should       == 8500
			reg.partner_type.should == "Merchant"
			reg.partner_id.should   == m1.id
			reg.type_of.should      == "debt"
		end

		it "should create dynamic in register for the merchant" do
			p = m1.provider
			p.update(rate: 96.5)
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 300)
			resp = Accountant.merchant(g)
			reg  = Register.last
			reg.gift_id.should      == g.id
			reg.origin.should       == "loc"
			reg.amount.should       == 9650
			reg.partner_type.should == "Merchant"
			reg.partner_id.should   == m1.id
			reg.type_of.should      == "debt"
		end

		it "should not double create register for merchant" do
			g     = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 300)
			resp  = Accountant.merchant(g)
			resp2 = Accountant.merchant(g)
			resp2.should be_true
			regs  = Register.all
			regs.count.should == 1
		end

		it "should use the price promo for 100 cat gift" do
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, receiver_id: u.id, value: "100", cost: "1.50", cat: 100, status: 'open')

			g.notify
			g.redeem_gift
			resp = Accountant.merchant(g)
			regs = Register.all
			regs.count.should == 1
			reg  = regs.first
			reg.gift_id.should      == g.id
			reg.origin.should       == "loc"
			reg.amount.should       == 150
			reg.partner_type.should == "Merchant"
			reg.partner_id.should   == m1.id
			reg.type_of.should      == "debt"
		end

		it "should use the price promo for 150 cat gift" do
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, receiver_id: u.id, value: "100", cost: "2", cat: 150, status: 'open')
			g.notify
			g.redeem_gift
			resp  = Accountant.merchant(g)
			resp2 = Accountant.merchant(g)
			resp2.should be_true
			regs = Register.all
			regs.count.should == 1
			reg  = regs.first
			reg.gift_id.should      == g.id
			reg.origin.should       == "loc"
			reg.amount.should       == 200
			reg.partner_type.should == "Merchant"
			reg.partner_id.should   == m1.id
			reg.type_of.should      == "debt"
		end

		it "should only pay the 150 gift on redemption, not creation" do
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, receiver_id: u.id, value: "100", cost: "2", cat: 150, status: 'open')
			g.status.should_not == 'redeemed'
			resp  = Accountant.merchant(g)
			regs = Register.all
			regs.count.should == 0
			g.notify
			g.redeem_gift
			resp  = Accountant.merchant(g)
			regs = Register.all
			regs.count.should == 1
			reg  = regs.first
			reg.gift_id.should      == g.id
			reg.origin.should       == "loc"
			reg.amount.should       == 200
			reg.partner_type.should == "Merchant"
			reg.partner_id.should   == m1.id
			reg.type_of.should      == "debt"
		end

		it "should do nothing for 200, 250 , any 7, any 1" do
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 200)
			resp  = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 201)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 207)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 250)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 251)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 257)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 301)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 307)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 101)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 107)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 151)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 157)
			resp = Accountant.merchant(g)
			resp.should == "no Debt Amount"
			Register.all.count.should == 0
		end

		it "should pay a redeemed gift if its has NOT already made a register with its parent gift" do
			m1.redemption!
			provider = m1.provider
			provider.redemption!

			gift = make_gift_sale(u, u, '200', provider.id)
			gift = Gift.find gift.id
			resp = Accountant.merchant(gift)
			Register.all.count.should == 0
			regift = regift_gift(gift)
			regift = Gift.find regift.id
			regift.notify
			regift.redeem_gift
			resp_regift = Accountant.merchant(regift)
			reg = Register.last
			reg.gift_id.should == resp_regift.gift_id
			Register.all.count.should == 1
			# resp_regift.should == false
		end

		it "should NOT pay a redeemed gift if its has already made a register with its parent gift" do
			# m1.redemption!
			provider = m1.provider
			# provider.redemption!

			gift = make_gift_sale(u, u, '200', provider.id)
			gift = Gift.find gift.id
			resp = Accountant.merchant(gift)
			Register.all.count.should == 1

			# m1.creation!
			# provider.creation!
			regift = regift_gift(gift)
			regift = Gift.find regift.id
			regift.notify
			regift.redeem_gift
			resp_regift = Accountant.merchant(regift)
			Register.all.count.should == 1
			# resp_regift.should == false
			reg = Register.last
			reg.gift_id.should == gift.id
			resp_regift.should == "Register exists"
		end
	end

	describe "affiliate" do

		let(:a1) { FactoryGirl.create(:affiliate)  }

		context "merchant affiliate" do

			before(:each) do
				a1.merchants << m1
			end

			it "should create debt in register for merchant affiliate" do
				g = FactoryGirl.create(:gift,
					provider_id: m1.provider.id,
				value: "100", cat: 300)
				resp = Accountant.affiliate_location(g)
				reg  = Register.last
				reg.gift_id.should      == g.id
				reg.origin.should       == "aff_loc"
				reg.amount.should       == 150
				reg.partner_type.should == "Affiliate"
				reg.partner_id.should   == a1.id
				reg.type_of.should      == "debt"
				a1.reload
				a1.payout_merchants.should  == 150
				affiliation = m1.affiliation
				affiliation.payout.should == 150
			end

			it "should not create debt if there is no merchant affiliate" do
				m = make_merchant_provider("not affiliated")
				g = FactoryGirl.create(:gift, provider_id: m.provider.id, value: "100", cat: 300)
				resp = Accountant.affiliate_location(g)
				resp.should == false
				Register.all.count.should == 0
			end

			it "should not create debt if merchant affiliation is not :on" do
				m1.affiliation.pause!
				g = FactoryGirl.create(:gift, provider_id:  m1.provider.id, value: "100", cat: 300)
				resp = Accountant.affiliate_location(g)
				resp.should == false
				Register.all.count.should == 0
			end

			it "should not double create register for merchant affiliate" do
				g = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 300)
				resp  = Accountant.affiliate_location(g)
				resp2 = Accountant.affiliate_location(g)
				resp2.should be_true
				regs  = Register.all
				regs.count.should == 1
			end

			it "should not create register for merchant aff when past total payout" do
				m1.affiliation.update(payout: 1000000)
				g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 300)
				resp = Accountant.affiliate_location(g)
				resp.should be_false
				Register.all.count.should == 0
			end

		end

		context "user affiliate" do

			let(:user) { FactoryGirl.create(:user) }

			before(:each) do
				a1.users << user
			end

			it "should create debt in register for user affiliate if one" do
				g = FactoryGirl.create(:gift, giver: user, value: "100", cat: 300)
				resp = Accountant.affiliate_user(g)
				reg  = Register.last
				reg.gift_id.should      == g.id
				reg.origin.should       == "aff_user"
				reg.amount.should       == 150
				reg.partner_type.should == "Affiliate"
				reg.partner_id.should   == a1.id
				reg.type_of.should      == "debt"
				a1.reload
				a1.payout_users.should  == 150
				affiliation = user.affiliation
				affiliation.payout.should == 150
			end

			it "should not create debt if there is no user affiliate" do
				not_user = FactoryGirl.create(:user)
				g = FactoryGirl.create(:gift, giver: not_user, value: "100", cat: 300)
				resp = Accountant.affiliate_user(g)
				resp.should == false
				Register.all.count.should == 0
			end

			it "should not create debt if user affiliation is not :on" do
				user.affiliation.pause!
				g = FactoryGirl.create(:gift, giver: user, value: "100", cat: 300)
				resp = Accountant.affiliate_user(g)
				resp.should == false
				Register.all.count.should == 0
			end

			it "should not double create register for user affiliate" do
				g = FactoryGirl.create(:gift, giver: user, value: "100", cat: 300)
				resp = Accountant.affiliate_user(g)
				resp2 = Accountant.affiliate_user(g)
				resp2.should == true
				Register.all.count.should == 1
			end

			it "should not create register for user aff when past total payout" do
				user.affiliation.update(payout: 10000)
				g = FactoryGirl.create(:gift, giver: user, value: "100", cat: 300)
				resp = Accountant.affiliate_user(g)
				resp.should == false
				Register.all.count.should == 0
			end

		end

		it "should require a gift" do
			g    ="Not a gift"
			resp = Accountant.affiliate_location(g)
			resp.should be_nil
			resp = Accountant.affiliate_user(g)
			resp.should be_nil
		end

		it "should do nothing for 100, 150, 200, 250 , any 7, any 1" do
			user = FactoryGirl.create(:user)
			a1.users << user
			a1.merchants << m1
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id, value: "100", cat: 200)
			resp  = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 201)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 207)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 250)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 251)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 257)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 100)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 101)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 107)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 150)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, provider_id: m1.provider.id,  value: "100", cat: 151)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, value: "100", cat: 157)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, value: "100", cat: 301)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			g = FactoryGirl.create(:gift, giver: user, value: "100", cat: 157)
			resp = Accountant.affiliate_user(g)
			resp2 = Accountant.affiliate_location(g)
			resp.should  be_false
			resp2.should be_false
			Register.all.count.should == 0
		end
	end

end