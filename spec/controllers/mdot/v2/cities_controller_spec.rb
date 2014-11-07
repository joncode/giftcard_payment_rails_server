require 'spec_helper'

include UserSessionFactory

describe Mdot::V2::CitiesController do

    before(:each) do
        @user = create_user_with_token "USER_TOKEN"
    end

    describe :index do

        it_should_behave_like("token authenticated", :get, :index)

        it "should return a list of all active cities serialized when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            keys    =  CITY_LIST[0].keys
            rrc(200)
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == CITY_LIST.count

            hsh = ary.first
            compare_keys(hsh, keys)
        end

        xit "should return 304 not modified on 2nd request" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(304)
        end
    end

    describe :merchants do

        it_should_behave_like("token authenticated", :get, :merchants, id: 1)

        it "should return a list of all active providers in city with id = <name> serialized when success" do
            Provider.delete_all
            20.times do
                FactoryGirl.create(:provider, region_id: 2)
            end
            Provider.last.update_attribute(:active, false)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: "New York"
            keys    =  ["city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live", "zinger", "desc"]
            rrc(200)
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == 19
            hsh = ary.first
            compare_keys(hsh, keys)
        end

        it "should return a list of all active providers in city with id = <integer> serialized when success" do
            Provider.delete_all
            20.times do
                FactoryGirl.create(:provider, region_id: 2)
            end
            Provider.last.update_attribute(:active, false)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: 2
            keys    =  ["city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live", "zinger", "desc"]
            rrc(200)
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == 19
            hsh = ary.first
            compare_keys(hsh, keys)
        end

        context "should return providers outside of city but in the region" do
            it "using region id" do
                Provider.delete_all
                FactoryGirl.create(:provider, name: "Abe's", city: "San Diego", region_id: 3)
                FactoryGirl.create(:provider, name: "Bob's", city: "La Jolla", region_id: 3)
                FactoryGirl.create(:provider, name: "Cam's", city: "New York", region_id: 2)
                request.env["HTTP_TKN"] = "USER_TOKEN"
                get :merchants, format: :json, id: 3
                rrc(200)
                ary = json["data"]
                ary.class.should == Array
                ary.count.should == 2
                ary[0]["name"].should == ("Abe's")
                ary[1]["name"].should == ("Bob's")
            end
            it "using region_id name" do
                Provider.delete_all
                FactoryGirl.create(:provider, name: "Abby's", city: "New York", region_id: 2)
                FactoryGirl.create(:provider, name: "Bobby's", city: "Jersey City", region_id: 2)
                FactoryGirl.create(:provider, name: "Cammy's", city: "San Diego", region_id: 3)
                request.env["HTTP_TKN"] = "USER_TOKEN"
                get :merchants, format: :json, id: "New York"
                rrc(200)
                ary = json["data"]
                ary.class.should == Array
                ary.count.should == 2
                ary[0]["name"].should == ("Abby's")
                ary[1]["name"].should == ("Bobby's")
            end
        end

        xit "should return 304 not modified on 2nd request" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: "New York"
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: "New York"
            rrc(304)
        end
    end

end
