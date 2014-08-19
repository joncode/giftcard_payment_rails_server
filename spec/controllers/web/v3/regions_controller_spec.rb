require 'spec_helper'

describe Web::V3::RegionsController do

    before(:each) do
        @provider = FactoryGirl.create(:provider, region_id: 2)
    end

    it "should return the cities" do
        get :index, format: :json, token: WWW_TOKEN
        keys    =  ["name", "state", "city_id", "token", "photo"]
        rrc(200)
        city = json["data"][0]
        compare_keys(city, keys)
    end

    it "should return the merchants in the region" do
        20.times do
            FactoryGirl.create(:provider, region_id: 2)
        end
        Provider.last.update(active: false)
        get :merchants, format: :json, id: 2, token: WWW_TOKEN
        rrc(200)

    end

end