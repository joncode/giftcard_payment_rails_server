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

    describe :credentials do
        it_should_behave_like("client-token authenticated", :get, :credentials)

        it "should return auth.net key and token and profile_id" do
            @user.update("cim_profile" => "826735482")
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            get :credentials, format: :json
            rrc(200)
            json["status"].should        == 1
            json["data"].class.should    == Hash
            json["data"]["key"].should   == AUTHORIZE_API_LOGIN
            json["data"]["token"].should == AUTHORIZE_TRANSACTION_KEY
            json["data"]["profile_id"].should == "826735482"
        end

        it "should return auth.net key and token and profile_id if profile_id is not made yet" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            Web::V3::CardsController.any_instance.stub(:get_cim_profile).and_return("")
            get :credentials, format: :json
            rrc(200)
            json["status"].should        == 1
            json["data"].class.should    == Hash
            json["data"]["key"].should   == AUTHORIZE_API_LOGIN
            json["data"]["token"].should == AUTHORIZE_TRANSACTION_KEY
            json["data"]["profile_id"].should == ""
        end
    end

    describe :create do
        it_should_behave_like("client-token authenticated", :post, :create)

        it "should not save incomplete card info" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "nickname"=>"Dango", "brand" => "Amex"}
            post :create, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json.class.should            == Hash
            json["err"].should   == "INCOMPLETE_INPUT"
            json["msg"].should   == "Missing Card Data"
        end

        it "should not save incomplete card info" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "last_four"=>"7483", "brand" => "Amex"}
            post :create, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json.class.should            == Hash
            json["err"].should   == "INCOMPLETE_INPUT"
            json["msg"].should   == "Missing Card Data"
        end

        it "should not save incomplete card info" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params = {"nickname"=>"Dango", "last_four"=>"7483", "brand" => "Amex"}
            post :create, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json.class.should            == Hash
            json["err"].should   == "INCOMPLETE_INPUT"
            json["msg"].should   == "Missing Card Data"
        end

        it "should not save incomplete card info" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "nickname"=>"Dango", "last_four"=>"7483"}
            post :create, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json.class.should            == Hash
            json["err"].should   == "INCOMPLETE_INPUT"
            json["msg"].should   == "Missing Card Data"
        end

        it "should accept hash of require fields and return card ID" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "nickname"=>"Dango", "last_four"=>"7483", "brand" => "Amex"}
            post :create, format: :json, data: params

            rrc(200)

            card = Card.find_by(user_id: @user.id)
            json["status"].should == 1
            json["data"].should   == { "card_id" => card.id, "nickname" => card.nickname, "last_four" => card.last_four, "brand" => "american_express" }
        end
    end

    describe :destroy do
        it_should_behave_like("client-token authenticated", :delete, :destroy, id: 1)

        let(:card) { FactoryGirl.create(:card, user_id: @user.id)  }

        it "should return card id in delete key on success" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            delete :destroy, format: :json, id: card.id
            rrc(200)
            json["status"].should == 1
            json["data"].should == card.id
        end

        it "should delete the card from the database" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            delete :destroy, format: :json, id: card.id
            card = Card.where(user_id: @user.id).count
            card.should == 0
        end

        it "should return 404 with no ID or wrong ID" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            delete :destroy, format: :json, id: 928312
            rrc(404)
        end
    end


end