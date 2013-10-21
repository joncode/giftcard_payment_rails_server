require 'spec_helper'

describe Admt::V2::ProvidersController do

    before(:each) do
        Provider.delete_all

         # should require valid admin credentials in every spec
        FactoryGirl.create(:admin_user, remember_token: "Token")
        request.env["HTTP_TKN"] = "Token"
    end

    describe :create do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :create, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        it "should create new merchant" do
            new_provider_hsh = {"name"=>"Yonaka Modern Japanese", "zinger"=>"A Perfect Bite To Inspire Conversation", "description"=>"We offer a Japanese Tapas style dining with a unique experience through Modern Japanese Cuisine. Yonaka provides a fresh and relaxing atmosphere with highly attentive and informative staff. ", "address"=>"4983 W Flamingo Road, Suite A", "city"=>"Las Vegas", "state"=>"NV", "zip"=>"89103", "phone"=>"7026858358", "merchant_id"=>34, "token"=>"_96WweqJfzLEZNbrtVREiw", "image"=>"blank_photo_profile.png", "mode"=>"coming_soon"}
            post :create, format: :json, data: new_provider_hsh
            provider = Provider.last
            provider.name.should        == new_provider_hsh["name"]
            provider.description.should == new_provider_hsh["description"]
            provider.zinger.should      == new_provider_hsh["zinger"]
            provider.city.should        == new_provider_hsh["city"]
            provider.state.should       == new_provider_hsh["state"]
            provider.zip.should         == new_provider_hsh["zip"]
            provider.address.should     == new_provider_hsh["address"]
            provider.phone.should       == new_provider_hsh["phone"]
            provider.token.should       == new_provider_hsh["token"]
            provider.merchant_id.should == new_provider_hsh["merchant_id"]
            provider.mode.should        == new_provider_hsh["mode"]
            provider.get_photo.should   == new_provider_hsh["image"]
            provider.active.should be_true
        end


        it "should create new menu_string" do
            new_provider_hsh = {"name"=>"Yonaka Modern Japanese", "zinger"=>"A Perfect Bite To Inspire Conversation", "description"=>"We offer a Japanese Tapas style dining with a unique experience through Modern Japanese Cuisine. Yonaka provides a fresh and relaxing atmosphere with highly attentive and informative staff. ", "address"=>"4983 W Flamingo Road, Suite A", "city"=>"Las Vegas", "state"=>"NV", "zip"=>"89103", "phone"=>"7026858358", "merchant_id"=>34, "token"=>"_96WweqJfzLEZNbrtVREiw", "image"=>"blank_photo_profile.png", "mode"=>"coming_soon"}
            new_provider_hsh['menu'] = "[{\"section\":\"Gift Vouchers\",\"items\":[{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"10\",\"item_id\":154,\"item_name\":\"$10\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"25\",\"item_id\":155,\"item_name\":\"$25\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"50\",\"item_id\":156,\"item_name\":\"$50\"}]}]"
            post :create, format: :json, data: new_provider_hsh
            provider                 = Provider.last
            menu_string              = MenuString.last
            response.response_code.should   == 200
            menu_string.provider_id.should  == provider.id
            menu_string.menu.should_not     be_nil
            menu_string.menu.should         == new_provider_hsh["menu"]
            json["status"].should == 1
            json["data"].should   == provider.id
        end

        it "should save latitude and longitude" do
            new_provider_hsh = {"name"=>"Yonaka Modern Japanese", "zinger"=>"A Perfect Bite To Inspire Conversation", "description"=>"We offer a Japanese Tapas style dining with a unique experience through Modern Japanese Cuisine. Yonaka provides a fresh and relaxing atmosphere with highly attentive and informative staff. ", "address"=>"4983 W Flamingo Road, Suite A", "city"=>"Las Vegas", "state"=>"NV", "zip"=>"89103", "phone"=>"7026858358", "merchant_id"=>34, "token"=>"_96WweqJfzLEZNbrtVREiw", "image"=>"blank_photo_profile.png", "mode"=>"coming_soon"}
            post :create, format: :json, data: new_provider_hsh
            provider = Provider.last
            provider.latitude.should    == new_provider_hsh["latitude"]
            provider.longitude.should   == new_provider_hsh["longitute"]
        end

    end

    describe "#deactivate" do

        it "should not allow unauthenticated access" do
            request.env["HTTP_TKN"] = "No_Entrance"
            put :deactivate, id: 1, format: :json
            response.response_code.should == 401
        end

        it "should deactivate 'live' provider" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            @new_provider = Provider.unscoped.find(provider.id)
            @new_provider.active.should be_false
        end

        it "should deactivate 'coming soon' provider" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            @new_provider = Provider.unscoped.find(provider.id)
            @new_provider.active.should be_false
        end

        it "should deactivate 'paused' provider" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:paused, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            @new_provider = Provider.unscoped.find(provider.id)
            @new_provider.active.should be_false
        end

        it "should deactivate merchant in MT" do
            merchant  = FactoryGirl.create(:merchant)
            provider  = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            new_provider = Provider.unscoped.find(provider.id)
            merchant = new_provider.merchant
            merchant.active.should be_false
        end

    end

    describe "#update_mode" do

        it "should not allow unauthenticated access" do
            request.env["HTTP_TKN"] = "No_Entrance"
            put :update_mode, id: 1, format: :json
            response.response_code.should == 401
        end

        it "should make 'paused' provider 'coming soon'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:paused, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "coming_soon"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "coming_soon"
        end

        it "should make 'paused' provider 'live'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:paused, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json, data: "live"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "live"
        end

        it "should make 'live' provider 'coming soon'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json, data: "coming_soon"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "coming_soon"
        end

        it "should make 'live' provider 'paused'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "paused"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "paused"
        end

        it "should make 'coming soon' provider 'live'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "live"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "live"
        end

        it "should make 'coming soon' provider 'paused'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "paused"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "paused"
        end

        it "should not change mode for incorrect mode and return error" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "wrong"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "coming_soon"
            json["status"].should == 0
            json["data"].should   == "Incorrect merchant mode sent - < wrong >"
        end

    end

end