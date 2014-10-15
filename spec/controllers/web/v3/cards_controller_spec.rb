require 'spec_helper'

describe Web::V3::CardsController do

    before(:each) do
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    describe :index do
        it_should_behave_like("client-token authenticated", :get, :index)

        it "should return a list of cards for the user" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            FactoryGirl.create(:card, user_id: @user.id)
            FactoryGirl.create(:amex, user_id: @user.id)
            FactoryGirl.create(:visa, user_id: @user.id)
            FactoryGirl.create(:mastercard, user_id: @user.id)

            get :index, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"].class.should  == Array
            json["data"].count.should  == 4
            keys = ['user_id', 'card_id', 'last_four', 'nickname']
            compare_keys(json["data"][0], keys)
        end

        it "should return an empty array if user has no cards" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"].class.should  == Array
            json["data"].count.should  == 0
        end
    end

    describe :create do
        it_should_behave_like("client-token authenticated", :post, :create)

        it "should accept hash of require fields and return card ID" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params =  {"month"=>"02", "number"=>"4417121029961508", "name"=>"Hiromi Tsuboi", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            card = Card.find_by(user_id: @user.id)
            rrc(200)
            json["status"].should == 1
            json["data"].should == { "user_id" => @user.id, "card_id" => card.id, "nickname" => card.nickname, "last_four" => card.last_four }
        end

        it "should return correct error message" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params =  {"month"=>"02", "number"=>"4417121029961508", "name"=>"Hiromi Tsuboi", "year"=>"2000", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            card = Card.find_by(user_id: @user.id)
            rrc(400)
            json["status"].should == 0
            json["err"].should == "INVALID_INPUT"
            json["msg"].should == "Your credit card information was bad."
            json["data"].should == [
                { "name" => "year", "msg" => "is not a valid year" },
                { "name" => "expiration", "msg" => "The expiration date must be in the future." }
            ]
        end

        it "should not save incomplete card info" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params = {"month"=>"02", "number"=>"4417121029961508", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            rrc(400)
        end

        it "should reject hash with fields not accept" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params = {"month"=>"02", "number"=>"4417121029961508", "fake" => "FAKE", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            rrc(400)
        end

    end

    # describe :create_token do
    #     it_should_behave_like("client-token authenticated", :post, :create)

    #     it "should not save incomplete card info" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         params = {"token"=>"25162732", "nickname"=>"Dango", "brand" => "Amex"}
    #         post :create_token, format: :json, data: params
    #         rrc(400)
    #         json["status"].should        == 0
    #         json.class.should            == Hash
    #         json["err"].should   == "INCOMPLETE_INPUT"
    #         json["msg"].should   == "Missing Card Data"
    #     end

    #     it "should not save incomplete card info" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         params = {"token"=>"25162732", "last_four"=>"7483", "brand" => "Amex"}
    #         post :create_token, format: :json, data: params
    #         rrc(400)
    #         json["status"].should        == 0
    #         json.class.should            == Hash
    #         json["err"].should   == "INCOMPLETE_INPUT"
    #         json["msg"].should   == "Missing Card Data"
    #     end

    #     it "should not save incomplete card info" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         params = {"nickname"=>"Dango", "last_four"=>"7483", "brand" => "Amex"}
    #         post :create_token, format: :json, data: params
    #         rrc(400)
    #         json["status"].should        == 0
    #         json.class.should            == Hash
    #         json["err"].should   == "INCOMPLETE_INPUT"
    #         json["msg"].should   == "Missing Card Data"
    #     end

    #     it "should not save incomplete card info" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         params = {"token"=>"25162732", "nickname"=>"Dango", "last_four"=>"7483"}
    #         post :create_token, format: :json, data: params
    #         rrc(400)
    #         json["status"].should        == 0
    #         json.class.should            == Hash
    #         json["err"].should   == "INCOMPLETE_INPUT"
    #         json["msg"].should   == "Missing Card Data"
    #     end

    #     it "should accept hash of require fields and return card ID" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         params = {"token"=>"25162732", "nickname"=>"Dango", "last_four"=>"7483", "brand" => "Amex"}
    #         post :create_token, format: :json, data: params

    #         rrc(200)

    #         card = Card.find_by(user_id: @user.id)
    #         json["status"].should == 1
    #         json["data"].should   == { "card_id" => card.id, "nickname" => card.nickname, "last_four" => card.last_four, "brand" => "american_express" }
    #     end
    # end

    # describe :destroy do
    #     it_should_behave_like("client-token authenticated", :delete, :destroy, id: 1)

    #     let(:card) { FactoryGirl.create(:card, user_id: @user.id)  }

    #     it "should return card id in delete key on success" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         delete :destroy, format: :json, id: card.id
    #         rrc(200)
    #         json["status"].should == 1
    #         json["data"].should == card.id
    #     end

    #     it "should delete the card from the database" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         delete :destroy, format: :json, id: card.id
    #         card = Card.where(user_id: @user.id).count
    #         card.should == 0
    #     end

    #     it "should return 404 with no ID or wrong ID" do
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         delete :destroy, format: :json, id: 928312
    #         rrc(404)
    #     end

    #     it "should delete the card from Auth.net" do
    #         @user.update("cim_profile" => "826735482")
    #         stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
    #                  with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<deleteCustomerPaymentProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <customerProfileId>826735482</customerProfileId>\n  <customerPaymentProfileId>72534234</customerPaymentProfileId>\n</deleteCustomerPaymentProfileRequest>\n",
    #                       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
    #                  to_return(:status => 200, :body => "", :headers => {})
    #         card.update(cim_token: "72534234")
    #         request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
    #         delete :destroy, format: :json, id: card.id
    #         rrc(200)

    #         WebMock.should have_requested(:post, "https://apitest.authorize.net/xml/v1/request.api").once
    #     end

    # end


end