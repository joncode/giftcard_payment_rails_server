require 'spec_helper'

describe Mt::V2::GiftsController do

    before(:each) do
        @provider = FactoryGirl.create(:provider)
        request.env["HTTP_TKN"] = @provider.token
        @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    end

    describe :create do

        it_should_behave_like("token authenticated", :post, :create)


        it "should 400 and extra or bad keys" do
            keys = ["receiver_name", "receiver_email", "shoppingCart", "message"]

            # too few keys
            post :create, format: :json, data: { "receiver_name" => "Fred Barry" }
            rrc 400

            # too many keys - bad shopping Cart
            too_many = { "receiver_name" => "Fred Barry", "receiver_email" => "test", "shoppingCart" => "test" , "message" => "test", "value" => "test"}
            post :create, format: :json, data: too_many
            rrc 400

            # correct amount with wrong names - bad shopping Cart
            too_many = { "name" => "Fred Barry", "email" => "test", "shoppingCart" => "test" , "message" => "test" }
            post :create, format: :json, data: too_many
            rrc 400

            # too many keys - good shopping cart
            too_many = { "receiver_name" => "Fred Barry", "receiver_email" => "test", "shoppingCart" => @cart , "message" => "test", "value" => "test"}
            post :create, format: :json, data: too_many
            rrc 400

            # correct amount with wrong names - good shopping cart
            too_many = { "name" => "Fred Barry", "email" => "test", "shoppingCart" => @cart, "message" => "test" }
            post :create, format: :json, data: too_many
            rrc 400

        end

        it "should create a promo gift and populate the provider with the token" do
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!"}
            post :create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_email: "fred@barry.com")
            biz_user = @provider.biz_user
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver.should         == biz_user
            gift.giver_name.should    == biz_user.name
            gift.receiver_name.should == "Fred Barry"
            gift.receiver_email.should == "fred@barry.com"
            gift.shoppingCart.should == @cart
            gift.message.should == "Check out Our Promotions!"
            gift.value.should   == "30"
        end

        it "should return 200 and a basic serialized gift" do
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!"}
            post :create, format: :json, data: create_hsh
            rrc 200
            json["status"].should == 1
            keys = ["value", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items"]
           compare_keys(json["data"], keys)
        end

        it "should return 400 plus validations message when validations dont pass" do
            create_hsh = { "receiver_name" => "", "receiver_email" => "test", "shoppingCart" => @cart, "message" => "test" }
            post :create, format: :json, data: create_hsh
            rrc 400
            json["status"].should == 0
            json["data"].keys.should == ["error"]
        end
    end

end