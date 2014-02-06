require 'spec_helper'

describe Mt::V2::GiftsController do

    before(:each) do
        @provider = FactoryGirl.create(:provider)
        request.env["HTTP_TKN"] = @provider.token
        @cart = "[{\"price\":\"10\",\"price_promo\":\"7\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    end

    describe :create do

        it_should_behave_like("token authenticated", :post, :create)


        it "should 400 and extra or bad keys" do
            keys = ["receiver_name", "receiver_email", "shoppingCart", "message", "expires_at"]

            # too few keys
            post :create, format: :json, data: { "receiver_name" => "Fred Barry" }
            rrc 400

            # too many keys - bad shopping Cart
            too_many = { "receiver_name" => "Fred Barry", "receiver_email" => "test", "shoppingCart" => "test" , "message" => "test", "value" => "test", "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: too_many
            rrc 400

            # correct amount with wrong names - bad shopping Cart
            too_many = { "name" => "Fred Barry", "email" => "test", "shoppingCart" => "test" , "message" => "test" , "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: too_many
            rrc 400

            # too many keys - good shopping cart
            too_many = { "receiver_name" => "Fred Barry", "receiver_email" => "test", "shoppingCart" => @cart , "message" => "test", "value" => "test", "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: too_many
            rrc 400

            # correct amount with wrong names - good shopping cart
            too_many = { "name" => "Fred Barry", "email" => "test", "shoppingCart" => @cart, "message" => "test" , "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: too_many
            rrc 400

        end

        it "should create a promo gift and populate the provider with the token" do
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_email: "fred@barry.com")
            biz_user = @provider.biz_user
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver.should         == biz_user
            gift.giver_name.should    == biz_user.name
            gift.expires_at.should    == "2014-06-12 06:59:59 UTC".to_datetime
            gift.receiver_name.should == "Fred Barry"
            gift.receiver_email.should == "fred@barry.com"
            gift.shoppingCart.should == @cart
            gift.message.should == "Check out Our Promotions!"
            gift.value.should   == "30"
            gift.cost.should    == "21"
        end

        it "should return 200 and a basic serialized gift" do
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: create_hsh
            rrc 200
            json["status"].should == 1
            keys = ["value", "cost", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items", "expires_at"]
            compare_keys(json["data"], keys)
        end

        it "should return 400 plus validations message when validations dont pass" do
            create_hsh = { "receiver_name" => "", "receiver_email" => "test", "shoppingCart" => @cart, "message" => "test", "expires_at"=>"2014-06-12 06:59:59 UTC" }
            post :create, format: :json, data: create_hsh
            rrc 400
            json["status"].should == 0
            json["data"].keys.should == ["error"]
        end

        it "should send an email to the receiver_email" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_email: "fred@barry.com")
            abs_gift_id = gift.id + NUMBER_ID
            run_delayed_jobs
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-notify-receiver"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\/#{abs_gift_id}/)
                else
                    true
                end
            }.once
        end

        it "should send in-network receivers a push notification" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            @receiver = FactoryGirl.create(:user, first_name: "Fred", last_name: "Barry", email: "fred@barry.com")
            @user = @provider.biz_user
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "expires_at"=>"2014-06-12 06:59:59 UTC"}
            post :create, format: :json, data: create_hsh
            rrc 200

            good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@user.name} sent you a gift at #{@provider.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            run_delayed_jobs
        end
    end

end







