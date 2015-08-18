require 'spec_helper'

describe Mt::V2::MerchantsController do

    before(:each) do
        request.env["HTTP_TKN"] = GENERAL_TOKEN

        Merchant.delete_all
    end

    describe :create do

        it_should_behave_like("token authenticated", :post, :create)

        it "should reject no params request" do
            put :create, format: :json
            response.response_code.should  == 400
        end

        it "should create new merchant" do
            new_merchant_hsh = {'city_id' => 2,"name"=>"Yonaka Modern Japanese", "r_sys" => 1, "zinger"=>"A Perfect Bite To Inspire Conversation", "description"=>"We offer a Japanese Tapas style dining with a unique experience through Modern Japanese Cuisine. Yonaka provides a fresh and relaxing atmosphere with highly attentive and informative staff. ", "address"=>"4983 W Flamingo Road, Suite A", "city"=>"Las Vegas", "state"=>"NV", "zip"=>"89103", "region_id" => 1, "phone"=>"7026858358", "token"=>"_96WweqJfzLEZNbrtVREiw", "image"=>"blank_photo_profile.png", "mode"=>"coming_soon", "pos_merchant_id" => 12345}
            post :create, format: :json, data: new_merchant_hsh
            merchant = Merchant.last
            merchant.name.should        == new_merchant_hsh["name"]
            merchant.description.should == new_merchant_hsh["description"]
            merchant.zinger.should      == new_merchant_hsh["zinger"]
            merchant.city_name.should        == new_merchant_hsh["city"]
            merchant.state.should       == new_merchant_hsh["state"]
            merchant.zip.should         == new_merchant_hsh["zip"]
            merchant.address.should     == new_merchant_hsh["address"]
            merchant.phone.should       == new_merchant_hsh["phone"]
            merchant.token.should       == new_merchant_hsh["token"]
            merchant.mode.should        == new_merchant_hsh["mode"]
            merchant.get_photo.should   == new_merchant_hsh["image"]
            merchant.r_sys.should       == 1
            merchant.pos_merchant_id.should == "12345"
            merchant.active.should be_true
        end


        it "should create new menu_string" do
            new_merchant_hsh = {'city_id' => 2,"name"=>"Yonaka Modern Japanese", "zinger"=>"A Perfect Bite To Inspire Conversation", "description"=>"We offer a Japanese Tapas style dining with a unique experience through Modern Japanese Cuisine. Yonaka provides a fresh and relaxing atmosphere with highly attentive and informative staff. ", "address"=>"4983 W Flamingo Road, Suite A", "city"=>"Las Vegas", "state"=>"NV", "zip"=>"89103", "region_id" => "1", "phone"=>"7026858358",  "token"=>"_96WweqJfzLEZNbrtVREiw", "image"=>"blank_photo_profile.png", "mode"=>"coming_soon"}
            new_merchant_hsh['menu'] = "[{\"section\":\"Gift Vouchers\",\"items\":[{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"10\",\"item_id\":154,\"item_name\":\"$10\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"25\",\"item_id\":155,\"item_name\":\"$25\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"50\",\"item_id\":156,\"item_name\":\"$50\"}]}]"
            post :create, format: :json, data: new_merchant_hsh
            merchant                 = Merchant.last
            menu_string              = merchant.menu
            response.response_code.should   == 200
            menu_string.id.should  == merchant.menu_id
            menu_string.json.should_not     be_nil
            menu_string.json.should         == new_merchant_hsh["menu"]
            json["status"].should           == 1
            json["data"].should             == merchant.id
        end

        it "should save latitude and longitude" do
            new_merchant_hsh = {'city_id' => 2,"name"=>"Yonaka Modern Japanese", "zinger"=>"A Perfect Bite To Inspire Conversation", "description"=>"We offer a Japanese Tapas style dining with a unique experience through Modern Japanese Cuisine. Yonaka provides a fresh and relaxing atmosphere with highly attentive and informative staff. ", "address"=>"4983 W Flamingo Road, Suite A", "city"=>"Las Vegas", "state"=>"NV", "zip"=>"89103", "region_id" => "1", "phone"=>"7026858358",  "token"=>"_96WweqJfzLEZNbrtVREiw", "image"=>"blank_photo_profile.png", "mode"=>"coming_soon"}
            new_merchant_hsh["latitude"]   = 43.23412141
            new_merchant_hsh["longitude"]  = -72.123124124
            post :create, format: :json, data: new_merchant_hsh
            merchant = Merchant.last
            merchant.latitude.should_not   be_nil
            merchant.longitude.should_not  be_nil
            merchant.latitude.should       == new_merchant_hsh["latitude"]
            merchant.longitude.should      == new_merchant_hsh["longitude"]
        end

    end

    describe :update do

        it_should_behave_like("token authenticated", :put, :update, id: 1)

        it "should reject no params request" do
            merchant = FactoryGirl.create(:merchant)
            request.env["HTTP_TKN"] = merchant.token
            put :update, id: merchant.id, format: :json
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
            image: "happy_photo_profile.png",
            pos_merchant_id: "54321"
        }.stringify_keys.each do |type_of, identifier|

            it "should update #{type_of}" do
                merchant = FactoryGirl.create(:merchant)
                request.env["HTTP_TKN"] = merchant.token
                new_merchant_hsh = { type_of => identifier }
                put :update, id: merchant.id, format: :json, data: new_merchant_hsh
                merchant = Merchant.find(merchant.id)
                merchant.send(type_of).should == identifier
            end

        end

        it "should not persist timezone (tz) to provider" do
            merchant = FactoryGirl.create(:merchant)
            request.env["HTTP_TKN"] = merchant.token
            new_merchant_hsh = { "tz" => "0-700" }
            put :update, id: merchant.id, format: :json, data: new_merchant_hsh
            rrc(400)
        end

    end


    describe :menu do

        before(:each) do
            @merchant = FactoryGirl.create(:merchant)
            request.env["HTTP_TKN"] = @merchant.token
            menu = FactoryGirl.create(:menu, merchant_id: @merchant.id)
            @merchant.update(menu_id: menu.id)
        end

        it_should_behave_like("token authenticated", :put, :menu, id: 1)

        it "should update menu string" do
            menu_json = "[{\"section\":\"Gift Vouchers\",\"items\":[{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"10\",\"item_id\":154,\"item_name\":\"$10\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"25\",\"item_id\":155,\"item_name\":\"$25\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"50\",\"item_id\":156,\"item_name\":\"$50\"}]}]"
            put :menu, id: @merchant.id, format: :json, data: menu_json
            rrc(200)
            @merchant.reload
            new_menu_string = @merchant.menu
            new_menu_string.json.should_not be_nil
            new_menu_string.json.should     == JSON.parse(menu_json).to_s
        end

        it "should return success msg if success" do
            menu_json = "[{\"section\":\"Gift Vouchers\",\"items\":[{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"10\",\"item_id\":154,\"item_name\":\"$10\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"25\",\"item_id\":155,\"item_name\":\"$25\"},{\"detail\":\"The entire gift amount must be used at one time.\\n\\t    Unused portions of this gift cannot be saved, transferred, or redeemed for cash.\",\"price\":\"50\",\"item_id\":156,\"item_name\":\"$50\"}]}]"
            put :menu, id: @merchant.id, format: :json, data: menu_json
            rrc(200)
            @merchant.reload
            json["status"].should  == 1
            json["data"].should   == "Menu Update Successful"
        end

        it "should return fail msg if menu is nil" do
            menu_json = nil
            put :menu, id: @merchant.id, format: :json, data: menu_json
            rrc(200)
            json["status"].should         == 0
            json["data"].class.should     == String
        end

        it "should return fail msg if menu is not a json'd array" do
            menu_json = "Menu Data"
            put :menu, id: @merchant.id, format: :json, data: menu_json
            rrc(200)
            json["status"].should         == 0
            json["data"].class.should     == String
        end
    end

    describe :reconcile do

        it_should_behave_like("token authenticated", :put, :reconcile, id: 1)

    end

end
