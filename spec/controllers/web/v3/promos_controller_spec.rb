require 'spec_helper'

include AffiliateFactory
include MerchantFactory
include UserSessionFactory
include MocksAndStubs
include LandingPageFactory
include CampaignFactory

describe Web::V3::PromosController do

	context "Standard" do
		before(:each) do
	        @client = make_partner_client('Client', 'Tester')
	        @user = create_user_with_token "USER_TOKEN", nil, @client
	        request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
	        request.env["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
	    end

		describe "show" do

			it_should_behave_like("client-token authenticated", :get, :show, id: 1)

			it "should require unique_landing_page_link return page_json of the landing page" do

				lp = FactoryGirl.create(:landing_page, link: "test_link", page_json: landing_page_json_fake)
				get :show, format: :json, id: "test_link"
				rrc(200)
				expect(json["status"]).to eq(1)
				expect(json["data"]).to eq(lp.page_json)
			end

			it "should return 404 if not found" do

				lp = FactoryGirl.create(:landing_page, link: "test_link")
				get :show, format: :json, id: "bad_link"
				rrc(404)
			end
		end

		describe "click" do

			it_should_behave_like("client-token authenticated", :patch, :click)

			it "should add count to a link" do

				lp = FactoryGirl.create(:landing_page, link: "testunique", clicks: 22)
				hsh= { "link" => lp.link}
				patch :click, format: :json, data: hsh
				rrc(200)
				lp.reload
				lp.clicks.should == 23
			end
		end

		describe "create" do
			it_should_behave_like("client-token authenticated", :post, :create)

			it "should require a link campaign_item_id rec_net_id & rec_net" do

		    	campaign, campaign_item, provider, affiliate, landing_page = affiliate_campaign
		        hsh = { "link" => landing_page.link, "c_item_id" => campaign_item.id, "rec_net" => "em", "rec_net_id" => "testy34@gmails.com" }

				post :create, format: :json, data: hsh
	            rrc(200)
	            json["status"].should == 1
	            keys = ['brand_card', 'multi_loc',"city_id", "region_id","r_sys", "region_name", "created_at", "giv_name", "giv_photo", "detail", "giv_id", "giv_type", "rec_name", "items", "value", "status", "expires_at", "cat", "msg", "loc_id", "loc_name", "loc_phone", "loc_address", "gift_id"]
	            compare_keys(json["data"], keys)
			end

			it "should persist the gift" do

		    	campaign, campaign_item, provider, affiliate, landing_page = affiliate_campaign
		        hsh = { "link" => landing_page.link, "c_item_id" => campaign_item.id, "rec_net" => "em", "rec_net_id" => "testy34@gmails.com" }

				post :create, format: :json, data: hsh
	            rrc(200)
	           	g = Gift.where(receiver_email: "testy34@gmails.com").first
	           	g.class.should == Gift
	           	g.payable_id.should == campaign_item.id
	           	g.client_id.should == @client.id
	           	g.partner_id.should == @client.partner.id
	           	g.partner_type.should == @client.partner.class.to_s
			end

			it "should return fail message when user already has a gift for campaign" do

		    	campaign, campaign_item, provider, affiliate, landing_page = affiliate_campaign
				email = "rece@gmails.com"
		        hsh = { "link" => landing_page.link, "c_item_id" => campaign_item.id, "rec_net" => "em", "rec_net_id" => email }
				old_gift = FactoryGirl.create(:gift, payable_id: campaign_item.id, giver_id: campaign.id, giver_type: "Campaign", receiver_email: email)

				post :create, format: :json, data: hsh
				rrc(200)
				json["status"].should == 0
				json["err"].should == "INVALID_INPUT"
				json["msg"].should == "Gift could not be created"
				json["data"].should == [{"msg"=>"Sorry, #{email} has already received a gift.  Each person is limited to one gift per campaign."}]
			end

		end
	end

    context "Redbull" do

        before(:each) do
            #   1. make a redbull partner
            #   2. make a thanks_redbull client
            @partner = make_affiliate("Thanks", "Redbull")
            @client = make_client_for_partner(@partner, :partner, :landing_page)
            #   3. make merchants and add to redbull_client
            @merchants = make_many_merchants(10, 'NYC Merchant')
            @merchants.each do |m|
                @client.content = m
            end
	        request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
	        request.env["HTTP_X_AUTH_TOKEN"] = REDBULL_TOKEN
        end

        #   5. test that it returns fail response for
        #       - bad email
        #       - bad merchant_id
        it "should return 400 bad request if email is not a valid email" do
        	hsh = { email: 'testexample.com', loc_id: @merchants[0].id }
			post :redbull, format: :json, data: hsh
            rrc(400)
        end

        it "should return a 404 not found if the merchant_id is not in Redbull client ids" do
        	hsh = { email: 'test@example.com', loc_id: 20834612 }
			post :redbull, format: :json, data: hsh
            rrc(404)
        end

        it "should generate a 40$ voucher and process the gift" do
	        #   6a. test promos/redbull generates a 40$ gift voucher if there is none
	        #   7b. test that promos/redbull with merchant_id and email generates a gift
	        #       - to the email address
	        #       - to the merchant
        	hsh = { email: 'testredbull@example.com', loc_id: @merchants[0].id }
			post :redbull, format: :json, data: hsh
            rrc(200)
        end

    end



end