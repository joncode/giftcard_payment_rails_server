require 'spec_helper'

describe Mdot::V2::CardsController do

    before(:each) do
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        it "should return a list of cards for the user" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
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
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"].class.should  == Array
            json["data"].count.should  == 0
        end
    end

    describe :tokenize do
        it_should_behave_like("token authenticated", :get, :tokenize)

        it "should return auth.net key and token" do
            @user.update("cim_profile" => "826735482")
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :tokenize, format: :json
            rrc(200)
            json["status"].should        == 1
            json["data"].class.should    == Hash
            json["data"]["key"].should   == AUTHORIZE_API_LOGIN
            json["data"]["token"].should == AUTHORIZE_TRANSACTION_KEY
            json["data"]["profile_id"].should == "826735482"
        end
    end

    describe :create_token do
        it_should_behave_like("token authenticated", :post, :create_token)

        it "should not save incomplete card info" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "nickname"=>"Dango", "brand" => "Amex"}
            post :create_token, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json["data"].class.should    == Hash
            json["data"]["error"].keys.should == ["last_four"]
        end

        it "should not save incomplete card info" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "last_four"=>"7483", "brand" => "Amex"}
            post :create_token, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json["data"].class.should    == Hash
            json["data"]["error"].keys.should == ["nickname"]
        end

        it "should not save incomplete card info" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"nickname"=>"Dango", "last_four"=>"7483", "brand" => "Amex"}
            post :create_token, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json["data"].class.should    == Hash
            json["data"]["error"].keys.should == ["cim_token"]
        end

        it "should not save incomplete card info" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "nickname"=>"Dango", "last_four"=>"7483"}
            post :create_token, format: :json, data: params
            rrc(400)
            json["status"].should        == 0
            json["data"].class.should    == Hash
            json["data"]["error"].keys.should == ["brand"]
        end

        it "should accept hash of require fields and return card ID" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"token"=>"25162732", "nickname"=>"Dango", "last_four"=>"7483", "brand" => "Amex"}
            post :create_token, format: :json, data: params

            rrc(200)

            card = Card.find_by(user_id: @user.id)
            json["status"].should == 1
            json["data"].should   == { "card_id" => card.id, "nickname" => card.nickname, "last_four" => card.last_four, "brand" => "american_express" }
        end
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

        it "should accept json'd hash of require fields and return card ID" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = "{\"month\":\"02\",\"number\":\"4417121029961508\",\"name\":\"Hiromi Tsuboi\",\"year\":\"2016\",\"csv\":\"910\",\"nickname\":\"Dango\"}"

            post :create, format: :json, data: params

            card = Card.find_by(user_id: @user.id)
            rrc(200)
            json["status"].should == 1
            json["data"].should == {"id" => card.id, "card_id" => card.id,"nickname" => card.nickname, "last_four" => card.last_four}
        end

        it "should accept hash of require fields and return card ID" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"month"=>"02", "number"=>"4417121029961508", "name"=>"Hiromi Tsuboi", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            card = Card.find_by(user_id: @user.id)
            rrc(200)
            json["status"].should == 1
            json["data"].should == {"id" => card.id, "card_id" => card.id, "nickname" => card.nickname, "last_four" => card.last_four}
        end

        it "should not save json'd incomplete card info" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = "{\"number\":\"4417121029961508\",\"name\":\"Hiromi Tsuboi\",\"year\":\"2016\",\"csv\":\"910\",\"nickname\":\"Dango\"}"

            post :create, format: :json, data: params
            rrc(400)
        end

        it "should not save incomplete card info" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"month"=>"02", "number"=>"4417121029961508", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            rrc(400)
        end

        it "should reject hash with fields not accept" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"month"=>"02", "number"=>"4417121029961508", "fake" => "FAKE", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            rrc(400)
        end

        it "should return validation errors with 200 code when failed validations" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"month"=>"0212312", "number"=>"4417121029961508", "name"=>"Hiromi Tsuboi", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            card = Card.find_by(user_id: @user.id)
            rrc(200)
            json["status"].should == 0
            json["data"]["error"].keys.include?("month").should be_true
        end

        it "should reject invalid cc numbers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"name"=>"Joe Meeks", "nickname"=>"junk", "number"=>"4222222222222222", "month"=>"10", "year"=>"2022", "csv"=>"123"}
            post :create, format: :json, data: params
            rrc(200)
            json["status"].should == 0
            json["data"]["error"].keys.include?("number").should be_true
        end

        it "should accept user id and brand BUG FIX" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"month"=>"1", "number"=>"4417121029961508", "user_id"=>1468, "brand"=>"Visa", "name"=>"Bobby Bobberson", "year"=>"2015", "csv"=>"999", "nickname"=>"Visa"}
            post :create, format: :json, data: params
            rrc(200)
            json["status"].should == 1
            card = Card.last
            card.month.should       == "1"
            card.user_id.should_not == 1468 #because it's overwritten in the controller
            card.user_id.should     == User.last.id #current user
            card.brand.should       == "visa"
            card.name.should        == "Bobby Bobberson"
            card.year.should        == "2015"
            card.csv.should         == "999"
            card.nickname.should    == "Visa"
        end

    end

    describe :destroy do
        it_should_behave_like("token authenticated", :delete, :destroy, id: 1)

        let(:card) { FactoryGirl.create(:card, user_id: @user.id)  }

        it "should return card id in delete key on success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            delete :destroy, format: :json, id: card.id
            rrc(200)
            json["status"].should == 1
            json["data"].should == card.id
        end

        it "should delete the card from the database" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            delete :destroy, format: :json, id: card.id
            card = Card.where(user_id: @user.id).count
            card.should == 0
        end

        it "should return 404 with no ID or wrong ID" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            delete :destroy, format: :json, id: 928312
            rrc(404)
        end
    end


end
