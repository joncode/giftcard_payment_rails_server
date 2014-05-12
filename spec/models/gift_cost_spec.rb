require 'spec_helper'

describe "Gift Costs" do

	before(:each) do
        @user     = FactoryGirl.create(:user)
        @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
        @provider = FactoryGirl.create(:provider)
	end

	after(:all) do
		Gift.delete_all
	end

    context "GiftSale / GiftSaleRegift" do

        before(:each) do
            @card     = FactoryGirl.create(:card, name: @user.name, user_id: @user.id)
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just Bought a Gift!"
            @gift_hsh["receiver_name"]  = @receiver.name
            @gift_hsh["receiver_id"]    = @receiver.id
            @gift_hsh["provider_id"]    = @provider.id
            @gift_hsh["giver"]          = @user
            @gift_hsh["value"]          = "45.00"
            @gift_hsh["service"]        = "2.25"
            @gift_hsh["credit_card"]    = @card.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
        end

        it "should calculate GiftSale cost from value" do
            @gift_sale = GiftSale.create @gift_hsh
            @gift_sale.cost.should == "38.25"
        end

        it "should transfer GiftSale cost to ReGift" do
            gift_sale   = GiftSale.create @gift_hsh
            regift_hsh = {}
            regift_hsh["message"]     = "I just REGIFTED!"
            regift_hsh["name"]        = "Bob"
            regift_hsh["email"]       = "bob@email.com"
        	regift_hsh["old_gift_id"] = gift_sale.id
            gift_regift = GiftRegift.create regift_hsh
            gift_regift.cost.should == "38.25"
        end
    end

	context "GiftPromo / GiftPromoRegift" do

        before(:each) do
	        @gift_hsh = {}
	        @gift_hsh["message"]        = "here is the promo gift"
	        @gift_hsh["receiver_name"]  = @receiver.name
	        @gift_hsh["receiver_email"] = @receiver.email
	        @gift_hsh["provider_id"]    = @provider.id
	        @gift_hsh["provider_name"]  = @provider.name
	        @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"price_promo\":\"8\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
        end

        it "should set GiftPromo cost to zero" do
            @gift_promo = GiftPromo.create @gift_hsh
            @gift_promo.cost.should == "0"
        end

        it "should transfer GiftPromo cost to ReGift" do
        # 	new_receiver = FactoryGirl.create(:user)
        #     gift_promo   = GiftPromo.create @gift_hsh
        #     regift_hsh = {}
        #     regift_hsh["message"]     = "I just REGIFTED!"
        #     regift_hsh["name"]        = "Bob"
        #     regift_hsh["email"]       = new_receiver.id
        # 	regift_hsh["old_gift_id"] = gift_promo.id
        #     gift_regift = GiftRegift.create regift_hsh
        #     gift_regift.cost.should == "0"
        end

        # it "should not allow ReGift of a GiftPromo" do
        #     @gift_promo   = GiftPromo.create @gift_hsh
        #     regift_hsh = {}
        #     regift_hsh["message"]     = "I just REGIFTED!"
        #     regift_hsh["name"]        = "Bob"
        #     regift_hsh["email"]       = "bob@email.com"
        # 	regift_hsh["old_gift_id"] = @gift_promo.id
        #     gift_regift = GiftRegift.create regift_hsh
        #     gift_regift.should == "You cannot regift a promotional gift"
        # end
    end

	context "GiftAdmin / GiftAdminRegift" do

		before(:each) do
	        @admin    = FactoryGirl.create(:admin_user)
	        @giver    = @admin.giver
	        @gift_hsh = {}
	        @gift_hsh["giver"]          = @giver
	        @gift_hsh["message"]        = "here is the admin gift"
	        @gift_hsh["receiver_name"]  = @receiver.name
	        @gift_hsh["receiver_email"] = @receiver.email
	        @gift_hsh["provider_id"]    = @provider.id
	        @gift_hsh["provider_name"]  = @provider.name
	        @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"price_promo\":\"7\",\"quantity\":1,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
	    end

	    it "should calculate GiftAdmin cost correctly from shoppingCart" do

	        gift_admin = GiftAdmin.create(@gift_hsh)
	        gift_admin.cost.should == "7"
	    end

        it "should transfer GiftAdmin cost to ReGift" do
            gift_admin   = GiftAdmin.create @gift_hsh
            regift_hsh = {}
            regift_hsh["message"]     = "I just REGIFTED!"
            regift_hsh["name"]        = "Bob"
            regift_hsh["email"]       = "bob@email.com"
        	regift_hsh["old_gift_id"] = gift_admin.id
            gift_regift = GiftRegift.create regift_hsh
            gift_regift.cost.should == "7"
        end
    end

	context "GiftCampaignAdmin / GiftCampaignAdminRegift" do

        before(:each) do
            @admin         = FactoryGirl.create(:admin_user)
            @admin_giver   = AdminGiver.find(@admin.id)
            @expiration    = (Time.now + 1.month).to_date
            @campaign      = FactoryGirl.create(:campaign, purchaser_type: "AdminGiver",
                                                           purchaser_id: @admin.id,
                                                           giver_name: "ItsOnMe Promotional Staff",
                                                           live_date: (Time.now - 1.week).to_date,
                                                           close_date: (Time.now + 1.week).to_date,
                                                           expire_date: (Time.now + 1.week).to_date,
                                                           budget: 100)
            @campaign_item = FactoryGirl.create(:campaign_item, provider_id: @provider.id,
                                                                campaign_id: @campaign.id,
                                                                message: "Enjoy this special gift on us!",
                                                                expires_at: @expiration,
                                                                shoppingCart: "[{\"price\":\"10\",\"price_promo\":\"1\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                                budget: 100,
                                                                value: "30",
                                                                cost: "3")
            @gift_hsh = {}
            @gift_hsh["receiver_name"]  = "Customer Name"
            @gift_hsh["receiver_email"] = "customer@gmail.com"
            @gift_hsh["payable_id"]     = @campaign_item.id
        end

        it "should calculate GiftCampaign cost from campaign item cost" do
            gift_campaign = GiftCampaign.create(@gift_hsh)
            gift_campaign.cost.should == "3"
        end

        it "should transfer GiftCampaign cost to ReGift" do
            gift_campaign = GiftCampaign.create(@gift_hsh)
            regift_hsh = {}
            regift_hsh["message"]     = "I just REGIFTED!"
            regift_hsh["name"]        = "Bob"
            regift_hsh["email"]       = "bob@email.com"
        	regift_hsh["old_gift_id"] = gift_campaign.id
            gift_regift = GiftRegift.create regift_hsh
            gift_regift.cost.should == "3"
        end
    end

	context "GiftCampaignMerchant / GiftCampaignMerchantRegift" do

        before(:each) do
            @biz_user  = BizUser.find(@provider.id)
            @expiration = (Time.now + 1.month).to_date
            @campaign   = FactoryGirl.create(:campaign, purchaser_type: "BizUser",
                                                           purchaser_id: @biz_user.id,
                                                           giver_name: "#{@biz_user.name} Staff",
                                                           live_date: (Time.now - 1.week).to_date,
                                                           close_date: (Time.now + 1.week).to_date,
                                                           expire_date: (Time.now + 1.week).to_date,
                                                           budget: 100)
            @campaign_item = FactoryGirl.create(:campaign_item, provider_id: @provider.id,
                                                                campaign_id: @campaign.id,
                                                                message: "Enjoy this special gift on us!",
                                                                expires_at: @expiration,
                                                                shoppingCart: "[{\"price\":\"10\",\"price_promo\":\"4\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                                budget: 100,
                                                                value: "30",
                                                                cost: "0")
            @gift_hsh = {}
            @gift_hsh["receiver_name"]  = "Customer Name"
            @gift_hsh["receiver_email"] = "customer@gmail.com"
            @gift_hsh["payable_id"]     = @campaign_item.id
        end

        it "should calculate GiftCampaign cost from campaign item cost" do
            gift_campaign = GiftCampaign.create(@gift_hsh)
            gift_campaign.cost.should == "0"
        end
        
        it "should transfer GiftCampaign cost to ReGift" do
            gift_campaign = GiftCampaign.create(@gift_hsh)
            regift_hsh = {}
            regift_hsh["message"]     = "I just REGIFTED!"
            regift_hsh["name"]        = "Bob"
            regift_hsh["email"]       = "bob@email.com"
        	regift_hsh["old_gift_id"] = gift_campaign.id
            gift_regift = GiftRegift.create regift_hsh
            gift_regift.cost.should == "0"
        end
    end

end
