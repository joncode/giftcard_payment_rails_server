require 'spec_helper'

include AffiliateFactory

describe "Affiliate Feature" do

	describe "users" do

		it "should associate user with affiliate via link" do
			a1 = make_affiliate("Afff", "One")
			a1.total_users.should == 0
			lp = FactoryGirl.create(:landing_page, link: "itson.me/san-diego?aid=twister_ice_tea", clicks: 2, affiliate_id: a1.id)
			new_aff_user = {"first_name" => "First", "email" => "aff@user.com", "password" => "passpass", "password_confirmation"=> "passpass", "last_name" => "archangle", "link" => "itson.me/san-diego?aid=twister_ice_tea" }
			u  = User.new(new_aff_user)
			u.save.should be_true
			a1.reload
			a1.total_users.should	  == 1
			a1.payout_links.should 	  == 0
			a1.value_links.should 	  == 0
			a1.users.count.should	  == 1
			a1.users.first.should	  == u
			lp.reload.users.should	  == 1
			u.affiliation.name.should == "First Archangle"
		end

	end

	describe "gifts" do

		it "should associate a gift with affiliate via link" do
			Gift.delete_all
			a1	 = make_affiliate("Afff", "One")
			a1.gifts.count.should == 0
			lp	 = FactoryGirl.create(:landing_page, link: "itson.me/san-diego?aid=twister_ice_tea", clicks: 2, affiliate_id: a1.id)
			p	 = FactoryGirl.create(:provider)
			receiver = FactoryGirl.create(:user)
			card = FactoryGirl.create(:card, user_id: receiver.id)
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{card.first_name},#{card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

			gift_hsh = {}
            gift_hsh["message"]        = "I just Bought a Gift!"
            gift_hsh["receiver_name"]  = receiver.name
            gift_hsh["receiver_id"]    = receiver.id
            gift_hsh["provider_id"]    = p.id
            gift_hsh["giver"]          = receiver
            gift_hsh["value"]          = "45.00"
            gift_hsh["service"]        = "2.25"
            gift_hsh["credit_card"]    = card.id
            gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            gift_hsh["link"] = "itson.me/san-diego?aid=twister_ice_tea"


			gift     = GiftSale.create(gift_hsh)
			gift.persisted?.should be_true
			db_gift  = Gift.find gift.id
			a1.reload
			# binding.pry
			a1.gifts.count.should	 == 1
			a1.gifts.first.should	 == db_gift
			lp.reload.gifts.should	 == 1
			a1.value_links.should	 == gift.value_in_cents
			a1.purchase_links.should == 1
			a1.payout_links.should	 == (gift.value_in_cents * 0.15 * 0.1).to_i

			aff_gfts = AffiliateGift.where(gift_id: db_gift.id)
			aff_gfts.where.not(affiliate_id: nil).first.affiliate_id.should == a1.id
			aff_gfts.where.not(landing_page_id: nil).first.landing_page_id.should == lp.id

		end


	end
end