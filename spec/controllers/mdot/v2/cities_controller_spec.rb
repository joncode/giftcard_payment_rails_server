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
            keys    =  Region.city.map(&:old_city_json)[0].keys
            rrc(200)
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == Region.city.map(&:old_city_json).count

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
                FactoryGirl.create(:provider)
            end

            Provider.last.update_attribute(:active, false)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: "New York"
            keys    =  ["region_id", "city_id","city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live", "zinger", "desc"]
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
                FactoryGirl.create(:provider)
            end
            Provider.last.update_attribute(:active, false)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :merchants, format: :json, id: 2
            keys    =  ["region_id", "region_name", "city_id","city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live", "zinger", "desc"]
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
                # binding.pry
                p = FactoryGirl.create(:provider, name: "Abe's")
                p.update(city: 'San Diego')
                p = FactoryGirl.create(:provider, name: "Bob's")
                p.update(city: 'San Diego')
                FactoryGirl.create(:provider, name: "Cam's")
                request.env["HTTP_TKN"] = "USER_TOKEN"
                get :merchants, format: :json, id: 2
                rrc(200)
                ary = json["data"]
                ary.class.should == Array
                ary.count.should == 3
                ary[0]["name"].should == ("Abe's")
                ary[1]["name"].should == ("Bob's")
            end
            it "using city_id name" do
                Provider.delete_all
                # binding.pry
                FactoryGirl.create(:provider, name: "Abby's")
                p = FactoryGirl.create(:provider, name: "Bobby's")
                p.update(city: "San Diego")
                p = FactoryGirl.create(:provider, name: "Cammy's")
                p.update(city: "San Diego")
                request.env["HTTP_TKN"] = "USER_TOKEN"
                get :merchants, format: :json, id: "New York"
                rrc(200)
                ary = json["data"]
                ary.class.should == Array
                ary.count.should == 3
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
