require 'spec_helper'

include UserSessionFactory

describe Web::V3::RegionsController do

    before(:each) do
        User.delete_all
        UserSocial.delete_all
        @provider = FactoryGirl.create(:provider, region_id: 2)
        request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
        @client = make_partner_client('Client', 'Tester')
        request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
         if Region.city.nil? || Region.city.count == 0
            load "#{Rails.root}/db/seeds.rb"
        end
    end

    it "should return the cities" do
        get :index, format: :json
        keys    =  ["name", "state", "region_id", "token", "photo", "city_id"]
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
        keys = [
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
        provider = json["data"][0]
        compare_keys(provider, keys)
    end

end