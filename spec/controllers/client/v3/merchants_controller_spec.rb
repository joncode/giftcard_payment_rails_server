require 'spec_helper'

describe Client::V3::MerchantsController do

    it "should return the merchant profile" do
        provider    = FactoryGirl.create(:provider, region_id: 1, image: "http://res.cloudinary.com/drinkboard/image/upload/v1349150293/upqygknnlerbevz4jpnw.png")
        menu_string = FactoryGirl.create(:menu_string, provider_id: provider.id)
        get :show, id: provider.id, format: :json
        rrc(200)
        json["data"]["address"].should == provider.complete_address
        json["data"]["live"].should    == 0
        json["data"]["photo"].should   == "d|v1349150293/upqygknnlerbevz4jpnw.png"
        json["data"]["region_id"].should == 1
    end

    it "should return the merchant menu" do
        provider    = FactoryGirl.create(:provider, region_id: 1, image: "http://res.cloudinary.com/drinkboard/image/upload/v1349150293/upqygknnlerbevz4jpnw.png")
        menu_string = FactoryGirl.create(:menu_string, provider_id: provider.id)
        get :menu, id: provider.id, format: :json
        rrc(200)

        json["status"].should == 1
        json["data"].class.should_not == String
        json["data"]["menu"].should   == menu_string.menu_json

    end
end