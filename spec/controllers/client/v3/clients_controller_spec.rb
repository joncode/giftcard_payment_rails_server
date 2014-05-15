require 'spec_helper'

describe Client::V3::ClientsController do


    it "should return the cities" do
        get :cities, format: :json
        keys    =  ["name", "state", "city_id", "photo"]
        # rrc(200)
        # hsh = json
        puts json.inspect
        # compare_keys(hsh, keys)
    end
end