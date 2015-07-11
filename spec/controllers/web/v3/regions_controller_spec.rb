require 'spec_helper'

include MerchantFactory
include UserSessionFactory

describe Web::V3::RegionsController do

    before(:each) do
        User.delete_all
        UserSocial.delete_all
        # @merchant = FactoryGirl.create(:provider, region_id: 2)
        m = make_merchant_provider('Make Content three')
        @merchant = m
        request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
        @client = make_partner_client('Client', 'Tester')
        request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
         if Region.city.nil? || Region.city.count == 0
            load "#{Rails.root}/db/seeds.rb"
        end
    end

    it "should return the cities" do
        @client.full!
        get :index, format: :json
        keys    =  ["name", "state", "region_id", "token", "photo", "city_id"]
        rrc(200)
        city = json["data"][0]
        compare_keys(city, keys)
    end

    it "should return only the cities for a client" do

        m1 = make_merchant_provider('Make Content one')
        m2 = make_merchant_provider('Make Content two')
        m3 = make_merchant_provider('Make Content three')
        @client.content = m1
        @client.content = m2
        # binding.pry
        get :index, format: :json
        keys    =  ["name", "state", "region_id", "token", "photo", "city_id"]
        rrc(200)
        json['data'].count.should == 2
        city = json["data"][0]
        compare_keys(city, keys)

    end


    it "should return the content merchants in the region" do
        m1 = make_merchant_provider('Make Content one')
        m2 = make_merchant_provider('Make Content two')
        m3 = make_merchant_provider('Make Content three')
        @client.content = m1
        @client.content = m2
        20.times do
            p = FactoryGirl.create(:provider)
            p.update(city_id: m1.city_id)

        end

        Provider.last.update(active: false)
        get :merchants, format: :json, id: m1.city_id
        rrc(200)
        # binding.pry
        json['data'].count.should == 1
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


    it "should return the merchants in the region" do
        @client.full!
        m1 = make_merchant_provider('Make Content one')
        m2 = make_merchant_provider('Make Content two')
        m3 = make_merchant_provider('Make Content three')
        @client.content = m1
        @client.content = m2
        20.times do
            m = FactoryGirl.create(:merchant)
            m.update(city_id: m1.city_id)

        end
        Merchant.last.update(active: false)
        get :merchants, format: :json, id: m1.city_id
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
        merchant = json["data"][0]
        compare_keys(merchant, keys)
    end

end