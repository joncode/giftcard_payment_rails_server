require 'spec_helper'

include UserSessionFactory

describe Mdot::V2::BrandsController do

    before(:each) do
        @user = create_user_with_token "USER_TOKEN"
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        before(:each) do
            Brand.delete_all
            20.times do |index|
                FactoryGirl.create(:brand, name: "Newbiee#{index}")
            end
            brand = Brand.last
            brand.update_attribute(:active, false)
        end

        it "should return a list of brands" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            amount  = Brand.where(active: true).count
            keys    = ["name","next_view","brand_id","photo"]
            get :index, format: :json
            rrc(200)
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
            hsh = ary.first
            compare_keys(hsh, keys)
        end

    end

    describe :merchants do
        it_should_behave_like("token authenticated",   :get, :merchants, id: 1)

        before(:each) do
            Brand.delete_all
            Provider.delete_all
            @brand = FactoryGirl.create(:brand, name: "newbie")
            20.times do |index|
                if index.even?
                    FactoryGirl.create(:provider, brand_id: @brand.id)
                else
                    FactoryGirl.create(:provider, building_id: @brand.id)
                end
            end
            provider = Provider.last
            provider.update_attribute(:active, false)
        end

        it "should return a list of providers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            amount  = Provider.where(active: true).count
            keys    =  ["city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live","zinger", "desc"]
            route   = :merchants
            get route, format: :json, id: @brand.id
            rrc(200)
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
            hsh = ary.first
            compare_keys(hsh, keys)
        end

        it "should return 404 when brand not found via ID" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: 100000
            rrc(404)
        end
    end

end