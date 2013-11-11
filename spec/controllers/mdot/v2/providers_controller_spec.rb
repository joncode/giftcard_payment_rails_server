require 'spec_helper'

describe Mdot::V2::ProvidersController do

    before(:all) do
        unless user = User.find_by_remember_token("USER_TOKEN")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    describe :menu do
        it_should_behave_like("token authenticated", :get, :menu, id: 1)

        before(:each) do
            @provider = FactoryGirl.create(:provider)
            FactoryGirl.create(:menu_string, provider_id: @provider.id)
            request.env["HTTP_TKN"] = "USER_TOKEN"
        end

        it "should return the provider menu in version 2 format only" do
            get :menu, id: @provider.id, format: :json
            rrc(200)
            json["status"].should == 1
            menu_json = json["data"]
            menu_json.class.should == String
            menu = JSON.parse menu_json
            keys = ["section", "items"]
            menu.class.should == Array
            compare_keys(menu[0], keys)
            items = menu[0]["items"]
            items.class.should == Array
            keys = ["detail", "price", "item_id", "item_name"]
            compare_keys(items[0], keys)
        end

        it "should return 404 if provider not found" do
            get :menu, id: 1000000, format: :json
            rrc(404)
        end
    end

    # describe :index do

    #     it_should_behave_like("token authenticated", :get, :index)

    #     it "should return a list of all active providers serialized when success" do
    #         20.times do
    #             FactoryGirl.create(:provider)
    #         end
    #         Provider.last.update_attribute(:active, false)
    #         request.env["HTTP_TKN"] = "USER_TOKEN"
    #         get :index, format: :json, data: "New York"
    #         keys    =  ["city", "latitude", "longitude", "name", "phone", "sales_tax", "provider_id", "photo", "full_address", "live"]
    #         response.response_code.should == 200
    #         ary = json
    #         ary.class.should == Array
    #         ary.count.should == 19
    #         hsh = ary.first
    #         keys.each do |key|
    #             hsh.has_key?(key).should be_true
    #         end
    #     end

    #     it "should return 302 not modified on 2nd request" do
    #         request.env["HTTP_TKN"] = "USER_TOKEN"
    #         get :index, format: :json
    #         request.env["HTTP_TKN"] = "USER_TOKEN"
    #         get :index, format: :json
    #         response.response_code.should == 302
    #     end
    # end

    # describe :show do
    #     it_should_behave_like("token authenticated", :get, :show, id: 1)

    # end

end
