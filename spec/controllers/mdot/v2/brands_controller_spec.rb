require 'spec_helper'

describe Mdot::V2::BrandsController do

    before(:all) do
        unless User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end

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
            request.env["HTTP_TKN"] = "TokenGood"
            amount  = Brand.where(active: true).count
            keys    = ["name","next_view","brand_id","photo"]
            get :index, format: :json
            response.response_code.should == 200
            ary = json
            ary.class.should == Array
            ary.count.should == amount
            hsh = ary.first
            keys.each do |key|
                hsh.has_key?(key).should be_true
            end
        end

    end

    describe :merchants do
        it_should_behave_like("token authenticated",   :get, :merchants, id: 1)

        before(:each) do
            Brand.delete_all
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
            request.env["HTTP_TKN"] = "TokenGood"
            amount  = Provider.where(active: true).count
            keys    =  ["city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live"]
            route   = :merchants
            get route, format: :json, id: @brand.id
            response.response_code.should == 200
            ary = json
            ary.class.should == Array
            ary.count.should == amount
            hsh = ary.first
            keys.each do |key|
                hsh.has_key?(key).should be_true
            end
        end

        it "should return 404 when brand not found via ID" do
            request.env["HTTP_TKN"] = "TokenGood"
            get :merchants, format: :json, id: 100000
            response.response_code.should == 404
        end
    end

end