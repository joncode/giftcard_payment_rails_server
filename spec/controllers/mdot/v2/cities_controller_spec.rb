require 'spec_helper'

describe Mdot::V2::CitiesController do

    before(:all) do
        unless user = User.find_by(remember_token: "USER_TOKEN")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    describe :index do

        it_should_behave_like("token authenticated", :get, :index)

        it "should return a list of all active providers serialized when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            keys    =  ["name", "state", "city_id", "photo"]
            rrc(200)
            ary = json
            ary.class.should == Array
            ary.count.should == 4
            hsh = ary.first
            compare_keys(hsh, keys)
        end

        xit "should return 302 not modified on 2nd request" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            response.response_code.should == 302
        end
    end

    describe :merchants do

        it_should_behave_like("token authenticated", :get, :merchants, id: 1)

        it "should return a list of all active providers serialized when success" do
            Provider.delete_all
            20.times do
                FactoryGirl.create(:provider)
            end
            Provider.last.update_attribute(:active, false)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: "New York"
            keys    =  ["city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live"]
            rrc(200)
            ary = json
            ary.class.should == Array
            ary.count.should == 19
            hsh = ary.first
            compare_keys(hsh, keys)
        end

        xit "should return 302 not modified on 2nd request" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: "New York"
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: "New York"
            response.response_code.should == 302
        end
    end

end
