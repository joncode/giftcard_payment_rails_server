require 'spec_helper'

include UserSessionFactory
include AffiliateFactory

describe Web::V3::CloverController do

    before(:each) do
        @controller = Web::V3::CloverController
        @client = make_partner_client('Client', 'Tester')
        @user = create_user_with_token "USER_TOKEN", nil, @client
        request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
        request.env["HTTP_X_AUTH_TOKEN"] = CLOVER_TOKEN
    end

	describe :initialize do
         it_should_behave_like("client-token authenticated", :post, :initialize)

        it "should accept hash of require fields and return client" do
            params =  { "slug1" => "las-vegas", "slug2" => "artifice", "ref" => "www.artifice.com" }

            post :initialize, format: :json
            rrc(200)
            json["status"].should == 1
        end
	end

    describe :redeem do
         it_should_behave_like("client-token authenticated", :patch, :redeem)

        it "should accept hash of require fields and return client" do
            params =  { "slug1" => "las-vegas", "slug2" => "artifice", "ref" => "www.artifice.com" }

            patch :redeem, format: :json
            rrc(200)
            json["status"].should == 1

        end
    end

end