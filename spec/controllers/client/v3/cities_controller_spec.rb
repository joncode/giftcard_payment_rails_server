require 'spec_helper'

describe Client::V3::CitiesController do

    before(:each) do
        @provider = FactoryGirl.create(:provider, region_id: 2)
    end

    it "should return the cities" do
        get :index, format: :json
        keys    =  ["name", "state", "city_id", "photo", "token"]
        rrc(200)
        city = json["data"][0]
        compare_keys(city, keys)
    end

    it "should return the merchants in the region" do
        20.times do
            FactoryGirl.create(:provider, region_id: 2)
        end
        Provider.last.update(active: false)
        get :merchants, format: :json, id: 2
        rrc(200)
    end

end