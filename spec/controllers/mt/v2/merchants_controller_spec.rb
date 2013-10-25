require 'spec_helper'

describe Mt::V2::MerchantsController do

    before(:each) do
        request.env["HTTP_TKN"] = GENERAL_TOKEN

        Provider.delete_all
    end

    describe :create do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :create, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        it "should reject no params request" do
            put :create, format: :json
            response.response_code.should  == 400
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
            json["status"].should           == 1
            json["data"].should             == provider.id
        end

        it "should save latitude and longitude" do
            new_provider_hsh = {"name"=>"Yonaka Modern Japanese", "zinger"=>"A Perfect Bite To Inspire Conversation", "description"=>"We offer a Japanese Tapas style dining with a unique experience through Modern Japanese Cuisine. Yonaka provides a fresh and relaxing atmosphere with highly attentive and informative staff. ", "address"=>"4983 W Flamingo Road, Suite A", "city"=>"Las Vegas", "state"=>"NV", "zip"=>"89103", "phone"=>"7026858358", "merchant_id"=>34, "token"=>"_96WweqJfzLEZNbrtVREiw", "image"=>"blank_photo_profile.png", "mode"=>"coming_soon"}
            new_provider_hsh["latitude"]   = 43.23412141
            new_provider_hsh["longitude"]  = -70.123124124
            post :create, format: :json, data: new_provider_hsh
            provider = Provider.last
            provider.latitude.should_not   be_nil
            provider.longitude.should_not  be_nil
            provider.latitude.should       == new_provider_hsh["latitude"]
            provider.longitude.should      == new_provider_hsh["longitude"]
        end

    end

    describe :update do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :update, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        it "should reject no params request" do
            provider = FactoryGirl.create(:provider)
            request.env["HTTP_TKN"] = provider.token
            put :update, id: provider.id, format: :json
            response.response_code.should  == 400
        end

        {
            name: "House Bar",
            description: "really crappy place",
            zinger: "www.fake.com",
            city: "San Selenas",
            state: "JK",
            zip: "89786",
            address: "123 happy town",
            phone: "6874567575",
            mode: "live",
            image: "happy_photo_profile.png"
        }.stringify_keys.each do |type_of, identifier|

            it "should update #{type_of}" do
                provider = FactoryGirl.create(:provider)
                request.env["HTTP_TKN"] = provider.token
                new_provider_hsh = { type_of => identifier }
                put :update, id: provider.id, format: :json, data: new_provider_hsh
                provider = Provider.find(provider.id)
                provider.send(type_of).should == identifier
            end

        end

        it "should not persist timezone (tz) to provider" do
            provider = FactoryGirl.create(:provider)
            request.env["HTTP_TKN"] = provider.token
            new_provider_hsh = { "tz" => "0-700" }
            put :update, id: provider.id, format: :json, data: new_provider_hsh
            response.response_code.should == 200

        end

    end


    describe :menu do

        before(:each) do
            @provider = FactoryGirl.create(:provider)
            request.env["HTTP_TKN"] = @provider.token
            FactoryGirl.create(:menu_string, provider_id: @provider.id)
        end

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :menu, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        it "should update menu string" do
            menu_string = @provider.menu_string
            menu_json = "[{\"section\":\"Gift Vouchers\",\"items\":[{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"10\",\"item_id\":154,\"item_name\":\"$10\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"25\",\"item_id\":155,\"item_name\":\"$25\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"50\",\"item_id\":156,\"item_name\":\"$50\"}]}]"
            put :menu, id: @provider.id, format: :json, data: menu_json
            response.response_code.should == 200
            new_menu_string = MenuString.last
            new_menu_string.menu.should_not be_nil
            new_menu_string.menu.should     == menu_json
        end

        it "should return success msg if success" do
            menu_string = @provider.menu_string
            menu_json = "[{\"section\":\"Gift Vouchers\",\"items\":[{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"10\",\"item_id\":154,\"item_name\":\"$10\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"25\",\"item_id\":155,\"item_name\":\"$25\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"50\",\"item_id\":156,\"item_name\":\"$50\"}]}]"
            put :menu, id: @provider.id, format: :json, data: menu_json
            response.response_code.should == 200
            new_menu_string = MenuString.last
            json["status"].should  == 1
            json["data"].should   == "Menu Update Successful"
        end

        it "should return fail msg if menu is nil" do
            menu_string = @provider.menu_string
            menu_json = nil
            put :menu, id: @provider.id, format: :json, data: menu_json
            response.response_code.should == 200
            json["status"].should         == 0
            json["data"].class.should     == Hash
        end

        it "should return fail msg if menu is not a json'd array" do
            menu_string = @provider.menu_string
            menu_json = "Menu Data"
            put :menu, id: @provider.id, format: :json, data: menu_json
            response.response_code.should == 200
            json["status"].should         == 0
            json["data"].class.should     == Hash
        end
    end

    describe :reconcile do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :reconcile, id: 1, format: :json
                response.response_code.should == 401
            end

        end

    end

end
