require 'spec_helper'

include UserSessionFactory

describe Web::V3::MerchantsController do

    before(:each) do
    	@merchant = FactoryGirl.create :merchant
        @provider = FactoryGirl.create :provider, merchant_id: @merchant.id
        request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
    end

    it "should return all of the providers" do
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
            "region_id"
        ]
        rrc(200)
        city = json["data"][0]
        compare_keys(city, keys)
    end

    it "should return the provider's menu" do
        menu_string = FactoryGirl.create(
        	:menu_string,
        	menu: "[{\"section\":\"Signature\",\"items\":[{\"detail\":\"PATRON CITRONGE, MUDDLED JALAPENOS\",\"price\":\"15\",\"item_id\":73,\"item_name\":\"JALAPENO MARGARITA\"}] }]",
        	provider_id: @provider.id
		)
    	get :menu, format: :json, id: @provider.id
    	rrc(200)
    	json["data"]["menu"].should == JSON.parse(menu_string.menu)
    end
end