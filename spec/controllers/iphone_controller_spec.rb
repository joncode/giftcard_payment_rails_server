require 'spec_helper'

describe IphoneController do

    describe :update_photo do

        before(:each) do
            User.delete_all

        end

        context "authorization" do

            it "should not allow unauthenticated access" do
                post :update_photo, format: :json, token: "No Way Entrance"
                response.response_code.should == 200
                json["error"].should  == "Data error, please log out and log back to reset system"
            end

        end

        let(:user) { FactoryGirl.create(:user) }

        it "should not run method when user is not found" do
            params_data = "{\"iphone_photo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            post :update_photo, data: params_data, format: :json
            response.response_code.should == 200
            json["error"].should   == "Data error, please log out and log back to reset system"
            json.keys.count.should == 1
        end

        it "should require an 'iphone_photo' key" do
            params_data = "{\"phoo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            response.response_code.should == 200
            json["error"].should   == "Photo upload failed, please check your connetion and try again"

        end

        it "should update 'iphone_photo' and 'user_photo'" do
            params_data = "{\"iphone_photo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            photo_pre   = "http://res.cloudinary.com/drinkboard/image/upload/v1382464405/myg7nfaccypfaybffljo.jpg"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            user_new = User.last
            user_new.use_photo.should    == 'ios'
            user_new.iphone_photo.should == photo_pre
            user_new.get_photo.should    == photo_pre
        end

        it "should return success msg when success" do
            params_data = "{\"iphone_photo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            response.response_code.should == 200
            json["success"].should   == "Photo Updated - Thank you!"

        end

        it "should send fail msgs when error" do
            params_data = "{\"iphone_photo\" : null }"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            response.response_code.should == 200
            json["error"].should   == "Photo upload failed, please check your connetion and try again"
        end

    end

    describe :create_account do

        context "authorization" do

            it "should not allow unauthenticated access" do
                post :update_photo, format: :json, token: "No Way Entrance"
                response.response_code.should == 200
                json["error"].should  == "Data error, please log out and log back to reset system"
            end

        end

        it "should hit urban airship endpoint with corect token and alias" do
            User.any_instance.stub(:ua_alias).and_return("fake_ua")
            User.any_instance.stub(:pn_token).and_return("FAKE_PN_TOKENFAKE_PN_TOKEN")
            pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            ua_alias = "fake_ua"
            Urbanairship.should_receive(:register_device).with(pn_token, { :alias => ua_alias})
            user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh, pn_token: pn_token
            run_delayed_jobs # ResqueSpec.perform_all(:push)
        end

    end

end





















