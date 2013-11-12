require 'spec_helper'

describe Mdot::V2::CardsController do

    before(:all) do
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

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

        it "should accept json'd hash of require fields and return card ID" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = "{\"month\":\"02\",\"number\":\"4417121029961508\",\"name\":\"Hiromi Tsuboi\",\"year\":\"2016\",\"csv\":\"910\",\"nickname\":\"Dango\"}"

            post :create, format: :json, data: params

            card = Card.find_by(user_id: @user.id)
            rrc(200)
            json["status"].should == 1
            json["data"].should == card.id
        end

        it "should accept hash of require fields and return card ID" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"month"=>"02", "number"=>"4417121029961508", "name"=>"Hiromi Tsuboi", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}

            post :create, format: :json, data: params

            card = Card.find_by(user_id: @user.id)
            rrc(200)
            json["status"].should == 1
            json["data"].should == card.id
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
