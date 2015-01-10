require 'spec_helper'

include UserSessionFactory

describe Mdot::V2::ProvidersController do

    before(:each) do
        @user = create_user_with_token "USER_TOKEN"
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
            provider_id = json["data"]["provider_id"]
            provider_id.should == @provider.id
            menu = json["data"]["menu"]
            menu.class.should == Array
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

    describe :receipt_photo_url do

        it_should_behave_like("token authenticated", :get, :receipt_photo_url, id: 1)

        before(:each) do
            @provider = FactoryGirl.create(:provider)
            FactoryGirl.create(:menu_string, provider_id: @provider.id)
            request.env["HTTP_TKN"] = "USER_TOKEN"
        end

        it "should return the default receipt photo url" do
            get :receipt_photo_url, id: @provider.id, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"].should == { "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL}

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
    #         rrc(200)
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
    #         rrc(302)
    #     end
    # end

    # describe :show do
    #     it_should_behave_like("token authenticated", :get, :show, id: 1)

    # end

end
