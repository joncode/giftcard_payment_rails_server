require 'spec_helper'

include UserSessionFactory
include MocksAndStubs
include LandingPageFactory
include CampaignFactory

describe Web::V3::PromosController do

	describe "show" do

		it_should_behave_like("client-token authenticated", :get, :show, id: 1)

		it "should require unique_landing_page_link return page_json of the landing page" do
			request.env["HTTP_X_AUTH_TOKEN"] = create_user_with_token("AUTH_TOKEN").remember_token
			lp = FactoryGirl.create(:landing_page, link: "test_link", page_json: landing_page_json_fake)
			get :show, format: :json, id: "test_link"
			rrc(200)
			expect(json["status"]).to eq(1)
			expect(json["data"]).to eq(lp.page_json)
		end

		it "should return 404 if not found" do
			request.env["HTTP_X_AUTH_TOKEN"] = create_user_with_token("AUTH_TOKEN").remember_token
			lp = FactoryGirl.create(:landing_page, link: "test_link")
			get :show, format: :json, id: "bad_link"
			rrc(404)
		end
	end

	describe "click" do

		it_should_behave_like("client-token authenticated", :patch, :click)

		it "should add count to a link" do
			request.env["HTTP_X_AUTH_TOKEN"] = create_user_with_token("AUTH_TOKEN").remember_token
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
			request.env["HTTP_X_AUTH_TOKEN"] = create_user_with_token("AUTH_TOKEN").remember_token
	    	campaign, campaign_item, provider, affiliate, landing_page = affiliate_campaign
	        hsh = { "link" => landing_page.link, "c_item_id" => campaign_item.id, "rec_net" => "em", "rec_net_id" => "testy34@gmails.com" }

			post :create, format: :json, data: hsh
            rrc(200)
            json["status"].should == 1
            keys = ["r_sys", "created_at", "giv_name", "giv_photo", "detail", "giv_id", "giv_type", "rec_name", "items", "value", "status", "expires_at", "cat", "msg", "loc_id", "loc_name", "loc_phone", "loc_address", "gift_id"]
            compare_keys(json["data"], keys)
		end

		it "should persist the gift" do
			request.env["HTTP_X_AUTH_TOKEN"] = create_user_with_token("AUTH_TOKEN").remember_token
	    	campaign, campaign_item, provider, affiliate, landing_page = affiliate_campaign
	        hsh = { "link" => landing_page.link, "c_item_id" => campaign_item.id, "rec_net" => "em", "rec_net_id" => "testy34@gmails.com" }

			post :create, format: :json, data: hsh
            rrc(200)
           	g = Gift.where(receiver_email: "testy34@gmails.com").first
           	g.class.should == Gift
           	g.payable_id.should == campaign_item.id
		end

		it "should return fail message when user already has a gift for campaign" do
			request.env["HTTP_X_AUTH_TOKEN"] = create_user_with_token("AUTH_TOKEN").remember_token
	    	campaign, campaign_item, provider, affiliate, landing_page = affiliate_campaign
			email = "rece@gmails.com"
	        hsh = { "link" => landing_page.link, "c_item_id" => campaign_item.id, "rec_net" => "em", "rec_net_id" => email }
			old_gift = FactoryGirl.create(:gift, payable_id: campaign_item.id, giver_id: campaign.id, giver_type: "Campaign", receiver_email: email)

			post :create, format: :json, data: hsh
			rrc(200)
			json["status"].should == 0
			json["err"].should == "INVALID_INPUT"
			json["msg"].should == "Gift could not be created"
			json["data"].should == ["Sorry, #{email} has already received a gift.  Each person is limited to one gift per campaign."]
		end

	end

end