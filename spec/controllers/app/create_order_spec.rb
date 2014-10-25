require 'spec_helper'

describe AppController do

    let(:gift)     { FactoryGirl.create(:gift) }
    let(:user)     { FactoryGirl.create(:user) }

    before(:each) do
        @gift = gift
        @gift.add_receiver(user)
        @gift.save
    end


    describe "#create_order" do

        it "should return the correct data on success" do
            @gift.notify
            post :create_order, format: :json, data: @gift.id, server_code: "test", token: user.remember_token
            json["success"].should == { "order_number" => @gift.token,  "total" => @gift.value, "server" => "test" }
        end

        it "should update the gift database" do
            @gift.notify
            post :create_order, format: :json, data: @gift.id, server_code: "test", token: user.remember_token
            json["success"]["order_number"].should == @gift.token
            json["success"]["total"].should ==        @gift.value
            json["success"]["server"].should ==       "test"
        end

    end

    describe "#create_order security" do

        it "it should not allow order creation for de-activated users" do
            user.update(active: false)
            post :create_order, format: :json, data: @gift.id, server_code: "test", token: user.remember_token
            json["error"].should == {"Failed Authentication"=>"Please log out and re-log into app"}
        end

    end


end