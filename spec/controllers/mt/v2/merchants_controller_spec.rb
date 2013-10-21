require 'spec_helper'

describe Mt::V2::MerchantsController do
    
    describe :update do

        before(:each) do
            request.env["HTTP_TKN"] = "1964f94b3e567a8a82b87f3ccbeb2174"

            Provider.delete_all
            #@provider = FactoryGirl.create(:provider)
        end

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :update, id: 1, format: :json
                response.response_code.should == 401
            end

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
            Provider.delete_all
            #@provider = FactoryGirl.create(:provider)
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

    describe "#reconcile" do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :reconcile, id: 1, format: :json
                response.response_code.should == 401
            end

        end

    end

end
