require 'spec_helper'
include MocksAndStubs

describe Admt::V2::GiftsController do

    before(:each) do
        #Gift.delete_all
        @provider = FactoryGirl.create(:provider)
        unless @admin_user = AtUser.find_by(remember_token: "Token")
            @admin_user = FactoryGirl.create(:admin_user, remember_token: "Token")
        end
        @user = FactoryGirl.create(:user)
        request.env["HTTP_TKN"] = "Token"
        @cart = "[{\"price\":\"10\",\"price_promo\":\"7\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    end

    describe :update do

        it_should_behave_like("token authenticated", :put, :update, id: 1)

        let(:gift) { FactoryGirl.create(:gift_no_association, giver: @user, giver_id: @user.id, provider: @provider) }

        it "should require a valid gift_id" do
            destroy_id = gift.id
            gift.destroy
            put :update, id: destroy_id, format: :json, data: { "receiver_name" => "JonBoy Shark"}
            response.response_code.should  == 404
        end

        it "should require a update hash" do
            put :update, id: gift.id, format: :json, data: "updated data"
            rrc(400)
            put :update, id: gift.id, format: :json, data: nil
            rrc(400)
            put :update, id: gift.id, format: :json
            rrc(400)
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "Jon Goodness"}
            rrc(200)
        end

        it "should return success msg when success" do
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "Jon Goodness"}
            json["status"].should == 1
            json["data"].should   == "#{gift.id} updated"
        end

        it "should return validation errors" do
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "" }
            json["status"].should     == 0
            json["data"].class.should == Hash
        end

        {
            receiver_name: "Ray Davies",
            receiver_email: "ray@davies.com",
            receiver_phone: "5877437859"
        }.stringify_keys.each do |type_of, value|

            it "should update the gift information in database" do
                put :update, id: gift.id, format: :json, data: { type_of => value }
                new_gift = Gift.last
                new_gift.send(type_of).should == value

            end
        end

        it "should not update attributes that are not allowed or dont exist" do
            hsh = { "house" => "chill" }
            put :update, id: gift.id, format: :json, data: hsh
            rrc(400)
        end

        it "should update from these params" do
            g_params = {"receiver_name"=>"Addis Dev", "receiver_email"=>"ta2@ta.com", "receiver_phone"=>"2052920036"}
            put :update, id: gift.id, format: :json, data: g_params
            response.response_code == 200
            json["status"].should == 1
            gift.reload
            gift.receiver_name.should == g_params["receiver_name"]
            gift.receiver_email.should == g_params["receiver_email"]
            gift.receiver_phone.should == g_params["receiver_phone"]
            json["data"].should_not be_nil

        end

    end

    describe :refund do

        it_should_behave_like("token authenticated", :put, :refund, id: 1)

        context "behavior" do

            let(:gift) { FactoryGirl.create(:gift_no_association, provider: @provider, giver: @user, giver_id: @user.id, pay_stat: 'charged', status: 'open', value: "134.00") }


            it "should set the gift 'pay_stat' to 'refund_comp' and not change the gift status" do
                auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,#{gift.value},CC,credit,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
                stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

                post :refund, id: gift.id, format: :json
                new_gift = Gift.find gift.id
                new_gift.pay_stat.should    == "refund_comp"
                new_gift.status.should_not  == 'cancel'
            end

            it "should not 500 when sending back 'reason text' for 'A valid referenced transaction ID is required.'" do
                auth_response = "3,2,33,A valid referenced transaction ID is required.,JVT36N,Y,345783945,,,#{gift.value},CC,credit,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
                stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
                post :refund, id: gift.id, format: :json
                json["status"].should == 0
                json["data"].should   == "A valid referenced transaction ID is required. ID = #{gift.id}."
            end

        end
    end

    describe :refund_cancel do

        it_should_behave_like("token authenticated", :put, :refund_cancel, id: 1)

        context "behavior" do

            let(:gift) { FactoryGirl.create(:gift_no_association, provider: @provider, giver: @user, giver_id: @user.id, pay_stat: 'charged', status: 'open', value: "134.00") }

            it "should set the gift 'pay_stat' to 'refund_cancel' and gift status to 'cancel' " do
                auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,#{gift.value},CC,credit,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
                stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
                post :refund_cancel, id: gift.id, format: :json
                new_gift = Gift.find gift.id
                new_gift.pay_stat.should == "refund_cancel"
                new_gift.status.should   == 'cancel'
            end

            it "should not 500 when sending back 'reason text' for 'A valid referenced transaction ID is required.'" do
                auth_response = "3,2,33,A valid referenced transaction ID is required.,JVT36N,Y,345783945,,,#{gift.value},CC,credit,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
                stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
                post :refund_cancel, id: gift.id, format: :json
                json["status"].should == 0
                json["data"].should   == "A valid referenced transaction ID is required. ID = #{gift.id}."
            end

        end
    end

    describe :add_receiver do

        it_should_behave_like("token authenticated", :put, :add_receiver, id: 1)

        before(:each) do
            resque_stubs
        end

        # context "gift has no receiver ID but unique receiver info - merge" do

        #     it "should merge user_id with receiver id and merge facebook_id" do
        #         gift = FactoryGirl.create(:gift, :facebook_id => "100005220484939")
        #         user = FactoryGirl.build(:user, :email => "christie.parker@gmail.com", phone: "7025237365")
        #         user.save
        #         put :add_receiver, id: gift.id, data: user.id, format: :json
        #         json["status"].should == 1
        #         rrc 200
        #         run_delayed_jobs
        #         gift.reload
        #         gift.receiver_id.should == user.id
        #         user = UserSocial.where(identifier: "christie.parker@gmail.com").first.user
        #         # user_social = UserSocial.where(identifier: "100005220484939", user_id: user.id)
        #         # user_social.count.should == 1
        #         user.phone.should       == "7025237365"
        #         user.facebook_id.should == "100005220484939"
        #     end

        #     it "should merge user_id with receiver id and merge twitter" do
        #         gift = FactoryGirl.create(:gift, :twitter => "9734658723658")
        #         user = FactoryGirl.create(:user, :email => "christie.parker2@gmail.com", phone: "7035237365")
        #         put :add_receiver, id: gift.id, data: user.id, format: :json
        #         json["status"].should == 1
        #         rrc 200
        #         run_delayed_jobs
        #         gift.reload
        #         gift.receiver_id.should == user.id
        #         user = UserSocial.where(identifier: "christie.parker2@gmail.com").first.user
        #         user.phone.should       == "7035237365"
        #         user_social = user.user_socials.where(identifier: "9734658723658").first
        #         user_social.should_not be_nil
        #     end

        #     it "should merge user_id with receiver id and merge receiver_email" do
        #         gift = FactoryGirl.create(:gift, :receiver_email => "new@gmail.com")
        #         user = FactoryGirl.create(:user, :email => "christie.parker4@gmail.com", phone: "7045237365")
        #         put :add_receiver, id: gift.id, data: user.id, format: :json
        #         json["status"].should == 1
        #         rrc 200
        #         run_delayed_jobs
        #         gift.reload
        #         gift.receiver_id.should == user.id
        #         user = UserSocial.where(identifier: "7045237365").first.user
        #         user.email.should == "new@gmail.com"
        #     end

        #     it "should merge user_id with receiver id and merge receiver_phone" do
        #         gift = FactoryGirl.create(:gift, :receiver_phone => "6567876574")
        #         user = FactoryGirl.create(:user, :email => "christie.parker4@gmail.com", phone: "7045237365")
        #         put :add_receiver, id: gift.id, data: user.id, format: :json
        #         json["status"].should == 1
        #         rrc 200
        #         run_delayed_jobs
        #         gift.reload
        #         gift.receiver_id.should == user.id
        #         user = UserSocial.where(identifier: "7045237365").first.user
        #         user.phone.should == "6567876574"
        #     end
        # end

        context "gift has the wrong receiver - changing receivers" do

            it "should remove old receiver info and add new receiver info and NOT merge socials" do
                bad_rec  = FactoryGirl.create(:user, email: "bad@receiver.com")
                good_rec = FactoryGirl.create(:user, email: "christie.parker@gmail.com", phone: "7025237365")
                gift = FactoryGirl.create(:gift)
                gift.remove_receiver
                gift.add_receiver(bad_rec)
                gift.save

                put :add_receiver, id: gift.id, data: good_rec.id, format: :json
                good_rec.reload
                good_rec.email.should_not == "bad@receiver.com"
            end

        end

    end

    describe :create do

        it_should_behave_like("token authenticated", :post, :create)

        it "should 400 when extra or bad keys" do
            keys = ["receiver_name", "receiver_email", "shoppingCart", "message", "expires_at", "provider_id", "provider_name"]

            # too few keys
            post :create, format: :json, data: { "receiver_name" => "Fred Barry" }
            rrc 400

            # too many keys - bad shopping Cart
            too_many = { "receiver_name" => "Fred Barry", "receiver_email" => "test", "shoppingCart" => "test" , "message" => "test", "value" => "test", "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: too_many
            rrc 400

            # correct amount with wrong names - bad shopping Cart
            too_many = { "name" => "Fred Barry", "email" => "test", "shoppingCart" => "test" , "message" => "test" , "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: too_many
            rrc 400

            # too many keys - good shopping cart
            too_many = { "receiver_name" => "Fred Barry", "receiver_email" => "test", "shoppingCart" => @cart , "message" => "test", "value" => "test", "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: too_many
            rrc 400

            # correct amount with wrong names - good shopping cart
            too_many = { "name" => "Fred Barry", "email" => "test", "shoppingCart" => @cart, "message" => "test" , "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: too_many
            rrc 400

        end

        it "should create an admin gift" do
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "detail" => "Good till midnight", "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_email: "fred@barry.com")
            admin_giver = @admin_user.giver
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver.should         == admin_giver
            gift.giver_name.should    == admin_giver.name
            gift.expires_at.should    == "2014-06-12 06:59:59 UTC".to_datetime
            gift.receiver_name.should == "Fred Barry"
            gift.receiver_email.should == "fred@barry.com"
            gift.shoppingCart.should  == @cart
            gift.message.should       == "Check out Our Promotions!"
            gift.value.should         == "30"
            gift.cost.should          == "21"
        end

        it "should return 200 and a basic serialized gift" do
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "detail" => "Good till midnight",  "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: create_hsh
            rrc 200
            json["status"].should == 1
            keys = ["value", "cost", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items", "expires_at", "cat", "detail"]
            compare_keys(json["data"], keys)
        end

        it "should return 400 plus validations message when validations dont pass" do
            create_hsh = { "receiver_name" => "", "receiver_email" => "test", "shoppingCart" => @cart, "message" => "test", "detail" => "Good till midnight",  "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name }
            post :create, format: :json, data: create_hsh
            rrc 400
            json["status"].should == 0
            json["data"].keys.should == ["error"]
        end

        it "should send an email to the receiver_email" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            GiftAdmin.any_instance.stub(:messenger_publish_gift_created)
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "detail" => "Good till midnight", "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_email: "fred@barry.com")
            abs_gift_id = gift.id + NUMBER_ID
            run_delayed_jobs
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-notify-receiver"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\?id=#{abs_gift_id}/)
                else
                    true
                end
            }.once
        end

        it "should send in-network receivers a push notification" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            GiftAdmin.any_instance.stub(:messenger_publish_gift_created)
            @receiver  = FactoryGirl.create(:user, first_name: "Fred", last_name: "Barry", email: "fred@barry.com")
            giver      = @admin_user.giver
            create_hsh = { "receiver_name" => "Fred Barry", "receiver_email" => "fred@barry.com", "shoppingCart" => @cart , "message" => "Check out Our Promotions!", "detail" => "Good till midnight",  "expires_at"=>"2014-06-12 06:59:59 UTC", "provider_id" => @provider.id, "provider_name" => @provider.name}
            post :create, format: :json, data: create_hsh
            rrc 200

            good_push_hsh = {
                :aliases => ["#{@receiver.ua_alias}"],
                :aps => {
                    :alert => "#{giver.name} sent you a gift at #{@provider.name}!",
                    :badge => 1,
                    :sound => "pn.wav"
                },
                :alert_type => 1,
                :android => {
                    :alert => "#{giver.name} sent you a gift at #{@provider.name}!",
                }
            }
            Urbanairship.should_receive(:push).with(good_push_hsh)
            run_delayed_jobs
        end
    end
end


























