require 'spec_helper'

include AffiliateFactory
include MerchantFactory
include UserSessionFactory

describe Web::V3::MerchantsController do

    context "Standard" do
        before(:each) do
        	@merchant = FactoryGirl.create :merchant
            request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
            @client = make_partner_client('Client', 'Tester')
            request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key

        end

        it "should return all of the merchants" do
            m1 = make_merchant_provider('Make Content one')
            m2 = make_merchant_provider('Make Content two')
            m3 = make_merchant_provider('Make Content three')
            @client.content = m1
            @client.content = m2
            20.times do
                p = FactoryGirl.create(:merchant)
                p.update(city_id: m1.city_id)

            end

            get :index, format: :json
            keys    =  [
                "latitude",
                "live",
                "loc_city",
                "loc_id",
                "loc_state",
                "loc_street",
                "loc_zip",
                "logo",
                "longitude",
                "name",
                "phone",
                "photo",
                "region_id",
                "city_id", "region_name"
            ]
            rrc(200)
            city = json["data"][0]
            compare_keys(city, keys)
        end

        it "should return the provider's menu" do
            menu_string = FactoryGirl.create(
            	:menu,
            	json: "[{\"section\":\"Signature\",\"items\":[{\"detail\":\"PATRON CITRONGE, MUDDLED JALAPENOS\",\"price\":\"15\",\"item_id\":73,\"item_name\":\"JALAPENO MARGARITA\"}] }]",
            	merchant_id: @merchant.id
    		)
            @merchant.update(menu_id: menu_string.id)

        	get :menu, format: :json, id: @merchant.id
        	rrc(200)
        	json["data"]["menu"].should == JSON.parse(menu_string.json)
        end

        describe :redeem_locations do

            it "should send the list of redemption locations if merchant has client" do

                m1 = make_merchant_provider('Make Content one')
                m2 = make_merchant_provider('Make Content two')
                m3 = make_merchant_provider('Make Content three')
                @client.content = m1
                @client.content = m2
                @client.content = m3
                @merchant.client = @client
                @merchant.save
                get :redeem_locations, format: :json, id: @merchant.id
                rrc(200)
                json["data"].length.should == 3
                example_loc = json["data"][0]['loc_id']
                [m1.id, m2.id, m3.id].include?(example_loc).should be_true
            end

            it "should send itself in array if merchant does not have client" do

                m4 = make_merchant_provider('Make Content four')

                get :redeem_locations, format: :json, id: m4.id
                rrc(200)
                json["data"].length.should == 1
                json['data'][0]['loc_id'].should == m4.id

            end

        end

        describe :receipt_photo_url do

            it "should return the default receipt photo url" do
                get :receipt_photo_url, id: @merchant.id, format: :json
                rrc(200)
                json["status"].should == 1
                json["data"].should == { "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL}

            end
        end

    end

    context :redbull do

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
            request.headers["HTTP_X_AUTH_TOKEN"] = REDBULL_TOKEN
            request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
        end


        it "should get client list of merchants from web/v3/merchants" do
            #   4. test that merchants with rebdull client key gives your those merchants
            #       - merchant_id
            #       - merchant_name
            #       - merchant_photo
            client = Client.find_by(application_key: @client.application_key)
            ms = client.contents(:merchants)
            ms.count.should == 10
            id_ary = @merchants.map(&:id)
            ms.each do |m|
                id_ary.include?(m.id).should be_true
            end
        end

        it "should return the merchants for the redbull client" do
            get :index, format: :json
            keys    =  [
                "latitude",
                "longitude",
                "live",
                "loc_city",
                "loc_id",
                "loc_state",
                "loc_street",
                "loc_zip",
                "logo",
                "name",
                "phone",
                "photo",
                "region_id",
                "city_id",
                "region_name"
            ]
            rrc(200)
            city = json["data"][0]
            compare_keys(city, keys)
            id_ary = json['data'].map{|m| m['loc_id'] }
            ms = @client.contents(:merchants)
            ms.count.should == 10
            ms.each do |m|
                id_ary.include?(m.id).should be_true
            end
        end

    end

end