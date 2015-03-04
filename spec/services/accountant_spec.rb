require 'spec_helper'

include MerchantFactory

describe Accountant do

	let(:m1) { make_merchant_provider("thirstys")  }

	describe "merchant" do

		it "should require a gift" do
			g    ="Not a gift"
			resp = Accountant.merchant(g)
			resp.should be_nil
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

		it "should not double create register for merchant" do
			g     = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 300)
			resp  = Accountant.merchant(g)
			resp2 = Accountant.merchant(g)
			resp2.should be_true
			regs  = Register.all
			regs.count.should == 1
		end

		it "should use the price promo for 100 cat gift" do
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cost: "1.50", cat: 100)
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
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cost: "2", cat: 150)
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

		it "should do nothing for 200, 250 , any 7, any 1" do
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 200)
			resp  = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 201)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 207)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 250)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 251)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 257)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 301)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 307)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 101)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 107)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 151)
			resp = Accountant.merchant(g)
			resp.should == false
			g    = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 157)
			resp = Accountant.merchant(g)
			resp.should == false
			Register.all.count.should == 0
		end
	end

	describe "affiliate" do

		let(:a1) { FactoryGirl.create(:affiliate)  }

		context "merchant affiliate" do

			before(:each) do
				a1.merchants << m1
			end

			it "should create debt in register for merchant affiliate" do
				g = FactoryGirl.create(:gift, provider_id: m1.provider.id, value: "100", cat: 300)
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