require 'spec_helper'

describe AppController do

    let(:redeem)   { FactoryGirl.create(:redeem) }
    let(:gift)     { redeem.gift }
    let(:user)     { FactoryGirl.create(:user) }

    before(:each) do
        @gift = gift
        @gift.add_giver(user)
        @gift.save
    end


    describe "#create_order" do

        it "should create an order for gift" do
            post :create_order, format: :json, data: @gift.id, server_code: "test", token: user.remember_token
            json["success"].should_not be_nil
        end

        it "should return the correct data on success" do
            post :create_order, format: :json, data: @gift.id, server_code: "test", token: user.remember_token
            order = Order.last
            @gift.reload
            json["success"].should == { "order_number" => @gift.order_num,  "total" => @gift.total, "server" => order.server_code }
        end

        it "should update the gift database" do
            post :create_order, format: :json, data: @gift.id, server_code: "test", token: user.remember_token
            @gift.reload
            json["success"]["order_number"].should == @gift.order_num
            json["success"]["total"].should ==        @gift.total
            json["success"]["server"].should ==       @gift.server
        end

    end

    describe "#create_order security" do

        it "it should not allow order creation for de-activated users" do
            user.update_attribute(:active, false)
            post :create_order, format: :json, data: @gift.id, server_code: "test", token: user.remember_token
            json["error"].should == {"Failed Authentication"=>"Please log out and re-log into app"}
        end

    end


end