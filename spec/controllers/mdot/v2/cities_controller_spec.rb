require 'spec_helper'

describe Mdot::V2::CitiesController do

    before(:all) do
        unless user = User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end
    end

    describe :index do

        it_should_behave_like("token authenticated", :get, :index)

        it "should return a list of all active providers serialized when success" do
            request.env["HTTP_TKN"] = "TokenGood"
            get :index, format: :json
            keys    =  ["name", "state", "city_id", "photo"]
            response.response_code.should == 200
            ary = json
            ary.class.should == Array
            ary.count.should == 4
            hsh = ary.first
            keys.each do |key|
                hsh.has_key?(key).should be_true
            end
        end

        xit "should return 302 not modified on 2nd request" do
            request.env["HTTP_TKN"] = "TokenGood"
            get :index, format: :json
            request.env["HTTP_TKN"] = "TokenGood"
            get :index, format: :json
            response.response_code.should == 302
        end
    end

    describe :merchants do

        it_should_behave_like("token authenticated", :get, :merchants, id: 1)


        it "should return a list of all active providers serialized when success" do
            20.times do
                FactoryGirl.create(:provider)
            end
            Provider.last.update_attribute(:active, false)
            request.env["HTTP_TKN"] = "TokenGood"
            get :merchants, format: :json, id: "New York"
            keys    =  ["city", "latitude", "longitude", "name", "phone", "sales_tax", "provider_id", "photo", "full_address", "live"]
            response.response_code.should == 200
            ary = json
            ary.class.should == Array
            ary.count.should == 19
            hsh = ary.first
            keys.each do |key|
                hsh.has_key?(key).should be_true
            end
        end

        xit "should return 302 not modified on 2nd request" do
            request.env["HTTP_TKN"] = "TokenGood"
            get :merchants, format: :json, id: "New York"
            request.env["HTTP_TKN"] = "TokenGood"
            get :merchants, format: :json, id: "New York"
            response.response_code.should == 302
        end
    end

end
