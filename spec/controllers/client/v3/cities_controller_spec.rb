require 'spec_helper'

describe Client::V3::CitiesController do


    it "should return the cities" do
        get :index, format: :json
        keys    =  ["name", "state", "city_id", "photo"]
        # rrc(200)
        # hsh = json
        puts json.inspect
        # compare_keys(hsh, keys)
    end

    it "should return the merchants in the region" do
        20.times do
            FactoryGirl.create(:provider, region_id: 2)
        end
        Provider.last.update(active: false)
        get :merchants, format: :json, id: 2
    end

    it "should return the provider menu in version 2 format only" do
        get :menu, id: @provider.id, format: :json
        rrc(200)
    end
end