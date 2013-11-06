require 'spec_helper'

describe Mdot::V2::PhotosController do

    before(:all) do
        unless user = User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end
        puts "---> user = #{user.inspect}"
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

        it "should require an 'data' key" do
            request.env["HTTP_TKN"] = "TokenGood"
            post :create, format: :json
            response.response_code.should == 400
        end

        it "should update 'iphone_photo' and 'user_photo'" do
            request.env["HTTP_TKN"] = "TokenGood"
            params_data = "http://res.cloudinary.com/drinkboard/image/upload/v1382464405/myg7nfaccypfaybffljo.jpg"
            post :create, data: params_data, format: :json
            user_new = User.find_by_remember_token("TokenGood")
            user_new.use_photo.should    == 'ios'
            user_new.iphone_photo.should == params_data
            user_new.get_photo.should    == params_data
        end

        it "should return success msg when success" do
            request.env["HTTP_TKN"] = "TokenGood"
            params_data = "http://res.cloudinary.com/drinkboard/image/upload/v1382464405/myg7nfaccypfaybffljo.jpg"
            post :create, data: params_data, format: :json
            response.response_code.should == 200
            json["status"].should == 1
            json["data"].should   == "Photo Updated - Thank you!"

        end

        it "should send fail msgs when empty string or nil or hash" do
            request.env["HTTP_TKN"] = "TokenGood"
            params_data = ""
            post :create, data: params_data, format: :json
            response.response_code.should == 400
            params_data = nil
            post :create, data: params_data, format: :json
            response.response_code.should == 400
            params_data = { "iphone_photo" => "djafhweiufhoawe"}
            post :create, data: params_data, format: :json
            response.response_code.should == 400
        end
    end

end

