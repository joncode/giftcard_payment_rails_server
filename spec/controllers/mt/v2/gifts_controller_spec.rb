require 'spec_helper'

describe Mt::V2::GiftsController do

    before(:each) do
        @provider = FactoryGirl.create(:provider)
        request.env["HTTP_TKN"] = @provider.token
        @cart = "[{\"price\":\"10\",\"price_promo\":\"7\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
        @expires_at = Time.now + 1.month
        @gp_mock = FactoryGirl.create :gift_promo_mock, receiver_name: "Fred Barry",
                                                        expires_at: @expires_at,
                                                        shoppingCart: @cart,
                                                        message: "Check out Our Promotions!"
        @gp_social = GiftPromoSocial.create(gift_promo_mock_id: @gp_mock.id, network: "email", network_id: "fred@barry.com")
    end

    describe :bulk_create do

        it_should_behave_like("token authenticated", :post, :bulk_create)


        it "should 400 and extra or bad keys" do
            keys = ["gift_promo_mock_id"]

            # too few keys
            post :bulk_create, format: :json, data: { }
            rrc 400

            # too many keys
            too_many = { "gift_promo_mock_id" => 1, "receiver_name" => "Fred Barry" }
            post :bulk_create, format: :json, data: too_many
            rrc 400

            # correct amount with wrong name
            too_many = { "name" => "Fred Barry" }
            post :bulk_create, format: :json, data: too_many
            rrc 400
        end

        it "should create a promo gift and find the provider via the token" do
            create_hsh = { "gift_promo_mock_id" => @gp_mock.id }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_email: "fred@barry.com")
            biz_user = @provider.biz_user
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver.should         == biz_user
            gift.giver_name.should    == biz_user.name
            gift.expires_at.should    == @expires_at
            gift.receiver_name.should == "Fred Barry"
            gift.receiver_email.should == "fred@barry.com"
            gift.shoppingCart.should == @cart
            gift.message.should == "Check out Our Promotions!"
            gift.value.should   == "30"
            gift.cost.should    == "0"
            gift.cat.should     == 200
        end

        it "should create a multple promo gifts and find the provider via the token" do
            GiftPromoSocial.create(gift_promo_mock_id: @gp_mock.id, network: "email", network_id: "greg@barry.com")
            GiftPromoSocial.create(gift_promo_mock_id: @gp_mock.id, network: "email", network_id: "harry@barry.com")
            create_hsh = { "gift_promo_mock_id" => @gp_mock.id }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200
            Gift.count.should == 3
            gift = Gift.find_by(receiver_email: "fred@barry.com")
            biz_user = @provider.biz_user
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver.should         == biz_user
            gift.giver_name.should    == biz_user.name
            gift.expires_at.should    == @expires_at
            gift.receiver_name.should == "Fred Barry"
            gift.receiver_email.should == "fred@barry.com"
            gift.shoppingCart.should == @cart
            gift.message.should == "Check out Our Promotions!"
            gift.value.should   == "30"
            gift.cost.should    == "0"
            gift.cat.should     == 200
            
            gift = Gift.find_by(receiver_email: "greg@barry.com")
            biz_user = @provider.biz_user
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver.should         == biz_user
            gift.giver_name.should    == biz_user.name
            gift.expires_at.should    == @expires_at
            gift.receiver_name.should == "Fred Barry"
            gift.receiver_email.should == "greg@barry.com"
            gift.shoppingCart.should == @cart
            gift.message.should == "Check out Our Promotions!"
            gift.value.should   == "30"
            gift.cost.should    == "0"
            gift.cat.should     == 200

            gift = Gift.find_by(receiver_email: "harry@barry.com")
            biz_user = @provider.biz_user
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver.should         == biz_user
            gift.giver_name.should    == biz_user.name
            gift.expires_at.should    == @expires_at
            gift.receiver_name.should == "Fred Barry"
            gift.receiver_email.should == "harry@barry.com"
            gift.shoppingCart.should == @cart
            gift.message.should == "Check out Our Promotions!"
            gift.value.should   == "30"
            gift.cost.should    == "0"
            gift.cat.should     == 200
        end

        it "should return 200 and a basic serialized gift" do
            create_hsh = { "gift_promo_mock_id" => @gp_mock.id }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200
            json["status"].should == 1
            keys = ["value", "cost", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items", "expires_at", "cat", "detail"]
            compare_keys(json["data"], keys)
        end

        it "should return 404 plus validations message gp_mock cannot be found" do
            create_hsh = { "gift_promo_mock_id" => "" }
            post :bulk_create, format: :json, data: create_hsh
            rrc 404
        end

        it "should send an email to the receiver_email" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            create_hsh = { "gift_promo_mock_id" => @gp_mock.id }
            post :bulk_create, format: :json, data: create_hsh
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
            create_hsh = { "gift_promo_mock_id" => @gp_mock.id }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200

            good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@user.name} sent you a gift at #{@provider.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            run_delayed_jobs
        end
    end

end
