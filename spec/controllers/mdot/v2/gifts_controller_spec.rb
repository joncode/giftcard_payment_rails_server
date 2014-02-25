require 'spec_helper'

describe Mdot::V2::GiftsController do

    describe :archive do
        it_should_behave_like("token authenticated", :get, :archive)

        before(:each) do
            UserSocial.delete_all
            User.delete_all
            Provider.delete_all
            @user = FactoryGirl.create(:user, email: "badge@gmail.com", twitter: "123", facebook_id: "7982364", active: true)
            @user.update(remember_token: "USER_TOKEN")
            @giver = FactoryGirl.create(:giver, email: "badged@gmail.com", twitter: "12f3", facebook_id: "79823d64", active: true)

            @number_received = 9
            @number_received.times do |n|
                gift =  FactoryGirl.build(:gift)
                gift.add_giver(@giver)
                gift.add_receiver(@user)
                gift.save
            end

            @number_sent = 12
            @number_sent.times do |n|
                gift =  FactoryGirl.build(:gift)
                gift.add_giver(@user)
                gift.add_receiver(@giver)
                gift.save
            end
        end

        it "should send a list of sent gifts" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :archive, format: :json
            json["status"].should == 1
            json["data"]["sent"].class.should == Array
            json["data"]["sent"].count.should == @number_sent
        end

        it "should send sent gifts (purchaser) with giver keys" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            keys = ["created_at", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "status", "cost", "value", "updated_at", "shoppingCart", "receiver_photo", "provider_photo", "provider_phone", "city", "live", "latitude", "longitude", "provider_address", "gift_id"]
            get :archive, format: :json
            gift_hsh = json["data"]["sent"][0]
            compare_keys(gift_hsh, keys)
        end

        it "should send a list of used gifts" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            gs = Gift.where(receiver_id: @user.id)
            gs.each do |gift|
                redeem = Redeem.find_or_create_with_gift(gift)
                gift.reload
                order  = Order.init_with_gift(gift, "xyz")
                order.save
            end
            get :archive, format: :json
            json["status"].should == 1
            json["data"]["used"].class.should == Array
            json["data"]["used"].count.should == @number_received
        end

        it "should send used gifts with receiver keys" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            gs = Gift.where(receiver_id: @user.id)
            gs.each do |gift|
                redeem = Redeem.find_or_create_with_gift(gift)
                gift.reload
                order  = Order.init_with_gift(gift, "xyz")
                order.save
            end
            keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "live", "latitude", "longitude", "provider_address", "gift_id", "updated_at", "created_at"]
            post :archive, format: :json
            gift_hsh = json["data"]["used"][0]
            compare_keys(gift_hsh, keys)
        end

        it "should send empty arrays when no gifts" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            Gift.delete_all
            get :archive, format: :json
            json["status"].should == 1
            json["data"]["sent"].class.should == Array
            json["data"]["sent"].count.should == 0
            json["data"]["used"].class.should == Array
            json["data"]["used"].count.should == 0
        end

        xit "should send redeemed and regifted drinks for 'used'" do

        end


    end

    describe :badge do
        it_should_behave_like("token authenticated", :get, :badge)

        before(:each) do
            UserSocial.delete_all
            User.delete_all
            Provider.delete_all
            @user = FactoryGirl.create(:user, email: "badge@gmail.com", twitter: "123", facebook_id: "7982364", active: true)
            @user.update_attribute(:remember_token, "USER_TOKEN"       )
            @giver = FactoryGirl.create(:giver, email: "badged@gmail.com", twitter: "12f3", facebook_id: "79823d64", active: true)
            @number = 10
            @number.times do |n|
                gift =  FactoryGirl.build(:gift)
                gift.add_giver(@giver)
                gift.add_receiver(@user)
                gift.save
            end
        end

        it "should return a correct badge count" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :badge, format: :json
            json["status"].should == 1
            json["data"]["badge"].should  == @number
        end

        it "should return gifts with deactivated givers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            @giver.update_attribute(:active, false)
            get :badge, format: :json
            json["status"].should == 1
            json["data"]["badge"].should  == @number
        end

        it "should not return gifts with deactivated receivers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            @user.update_attribute(:active, false)
            get :badge, format: :json
            rrc(401)
        end

        it "should not return gifts that are unpaid" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            gs = Gift.where(receiver_id: @user.id)
            total_changed = 2
            gift1 = gs[0]
            gift1.update_attribute(:pay_stat, 'unpaid')
            gift2 = gs[1]
            gift2.update_attribute(:pay_stat, 'unpaid')
            get :badge, format: :json
            json["status"].should == 1
            json["data"]["badge"].should == (@number - total_changed)
        end

        it "should return receiver serialized gifts" do
            keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "gift_id", "updated_at", "created_at"]
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :badge, format: :json
            json_gifts = json["data"]["gifts"]
            json_gifts.class.should == Array
            serialized_gift = json_gifts[0]
            compare_keys(serialized_gift, keys)
        end

        it "should return shopping cart as a json Array" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :badge, format: :json
            gifts_ary = json["data"]["gifts"]
            gifts_ary[0]["shoppingCart"].class.should == Array
        end

        context "scope out unpaid / expired gifts" do

            it "should not return :pay_stat => 'payment_error' gifts" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                gifts = Gift.where(receiver_id: @user.id)
                last_gift = gifts.pop
                gifts.each do |gift|
                    gift.update(pay_stat: "payment_error" )
                end

                get :badge, format: :json
                json["data"]["badge"].should == 1
                gift = json["data"]["gifts"].pop

                gift["gift_id"].should == last_gift.id
            end

            it "should not return :status => 'expired' gifts" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                gifts = Gift.where(receiver_id: @user.id)
                last_gift       = gifts.pop
                other_last_gift = gifts.pop
                gifts.each do |gift|
                    gift.update(status: "expired")
                end
                get :badge, format: :json
                json["data"]["badge"].should == 2
                gift = json["data"]["gifts"].pop
                gift["gift_id"].should       == last_gift.id
            end
        end

        it "should send gifts when providers are paused / not live / deactivated" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            gift = Gift.find_by(giver_id: @giver)
            provider = gift.provider
            provider.deactivate

            get :badge, format: :json
            json["data"]["badge"].should == @number
        end
    end

    describe :open do
        it_should_behave_like("token authenticated", :post, :open, id: 1)

        before(:each) do
            ResqueSpec.reset!
            UserSocial.delete_all
            User.delete_all
            Provider.delete_all
            @user = FactoryGirl.create(:user, email: "badge@gmail.com", twitter: "123", facebook_id: "7982364", active: true)
            @user.update_attribute(:remember_token, "USER_TOKEN")
            @giver = FactoryGirl.create(:giver, email: "badged@gmail.com", twitter: "12f3", facebook_id: "79823d64", active: true)
            @gift =  FactoryGirl.build(:gift, status: 'open')
            @gift.add_giver(@giver)
            @gift.add_receiver(@user)
            @gift.save
        end

        it "should create a redeem for the gift" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            rrc(200)
            redeem = @gift.redeem
            redeem.class.should == Redeem
        end

        it "should return the redeem code on success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            rrc(200)
            json["status"].should == 1
            json["data"].should == @gift.redeem.redeem_code
        end

        it "should change the gift status to 'notified'" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            @gift.reload
            rrc(200)
            @gift.status.should == 'notified'
        end

        xit "should return validation errors if validation fail" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            json["status"].should == 0
        end

        it "should reject request if params are attached" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            fake_params = { "fake" => "FAKE" }
            post :open, format: :json, id: @gift.id, faker: fake_params
            rrc(400)
        end

        it "should return 404 if gift id not found" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: 0
            rrc(404)
        end

        it "should not allow opening gifts that user does not receive" do
            other = FactoryGirl.create(:receiver)
            @gift =  FactoryGirl.build(:gift, status: 'open')
            @gift.add_giver(@giver)
            @gift.add_receiver(other)
            @gift.save

            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            rrc(404)
        end

        it "should send a 'your gift is opened' push to the gift giver" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            badge = Gift.get_notifications(@gift.giver)
            user_alias = @gift.giver.ua_alias
            good_push_hsh = {:aliases =>["#{user_alias}"],:aps =>{:alert => "#{@gift.receiver_name} opened your gift at #{@gift.provider_name}!",:badge=>badge,:sound=>"pn.wav"},:alert_type=>2}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            run_delayed_jobs
        end
    end

    describe :redeem do
        it_should_behave_like("token authenticated", :post, :redeem, id: 1)

        before(:each) do
            UserSocial.delete_all
            User.delete_all
            Provider.delete_all
            @user = FactoryGirl.create(:user, email: "badge@gmail.com", twitter: "123", facebook_id: "7982364", active: true)
            @user.update_attribute(:remember_token, "USER_TOKEN")
            @giver = FactoryGirl.create(:giver, email: "badged@gmail.com", twitter: "12f3", facebook_id: "79823d64", active: true)
            @gift =  FactoryGirl.build(:gift, status: 'open')
            @gift.add_giver(@giver)
            @gift.add_receiver(@user)
            @gift.save
            redeem = Redeem.find_or_create_with_gift(@gift)
        end

        it "should create an order for the gift" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: @gift.id, server: "test"
            @gift.order.class.should == Order
            @gift.order.server_code.should == "test"
        end

        it "should return order_number, server, and total on success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: @gift.id, server: "test"
            order = @gift.order
            rrc(200)
            json["status"].should == 1

            json["data"]["order_number"].should == order.make_order_num
            json["data"]["total"].should        == @gift.value + ".00"
            json["data"]["server"].should       == "test"
        end

        it "should return order_number, server, and total on success when no server value is included" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: @gift.id, server: ""
            order = @gift.order
            rrc(200)
            json["status"].should == 1

            json["data"]["order_number"].should == order.make_order_num
            json["data"]["total"].should        == @gift.value + ".00"
            json["data"]["server"].should       == ""
        end

        it "should return order_number, server, and total on success when no server key" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: @gift.id
            order = @gift.order
            rrc(200)
            json["status"].should == 1

            json["data"]["order_number"].should == order.make_order_num
            json["data"]["total"].should        == @gift.value + ".00"
            json["data"]["server"].should       == ""
        end

        it "should update gift server, redeemed_at" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            time = Time.now
            @gift.redeemed_at.should be_nil
            post :redeem, format: :json, id: @gift.id, server: "test"
            @gift.reload
            @gift.status.should == 'redeemed'
            @gift.server.should == "test"
            @gift.redeemed_at.day.should == time.day
        end

        it "should return validation errors on bad gift" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            redeem = Redeem.find_by(gift_id: @gift.id)
            redeem.destroy
            post :redeem, format: :json, id: @gift.id, server: "test"
            rrc(400)
            json["status"].should == 0
            json["data"].should   == { "error" => { "gift_id"=>["can't be blank"], "redeem_id"=>["can't be blank"], "provider_id"=>["can't be blank"] } }
        end

        it "should reject request if request is malformed" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: @gift.id, server: "test", faker: "FAKE"
            rrc(400)
        end

        it "should return data transfer error if @gift not found" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: 0, server: "test"
            rrc(404)
        end

        it "should not allow redeeming gifts that user does not receive" do
            other = FactoryGirl.create(:receiver)
            @gift =  FactoryGirl.build(:gift, status: 'open')
            @gift.add_giver(@giver)
            @gift.add_receiver(other)
            @gift.save
            redeem = Redeem.find_or_create_with_gift(@gift)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: @gift.id, server: "test"
            rrc(404)
        end

    end

    describe :regift do
        it_should_behave_like("token authenticated", :post, :regift, id: 1)

        before(:each) do
            Gift.delete_all
            User.delete_all
            UserSocial.delete_all
            @user = FactoryGirl.create(:user, email: "badge@gmail.com", twitter: "123", facebook_id: "7982364", active: true)
            @user.update_attribute(:remember_token, "USER_TOKEN")
            @giver = FactoryGirl.create(:giver, email: "badged@gmail.com", twitter: "12f3", facebook_id: "79823d64", active: true)
            @gift =  FactoryGirl.build(:gift, status: 'open', active: true)
            @gift.add_giver(@giver)
            @gift.add_receiver(@user)
            @gift.save

        end

        let(:cart) { "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]" }

        describe "#regift" do

            let(:old_gift)  { @gift }
            let(:giver)     { @giver }
            let(:regifter)  { @user }
            let(:receiver)  { FactoryGirl.create(:receiver) }
            let(:rec_hsh)  { regift_hash(receiver) }

            it "should create a new gift w JSON receiver hash" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: regift_hash(receiver) }
                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.find(old_gift.id + 1)
                new_gift.status.should == 'open'
                new_gift.payable_id.should == old_gift.id
            end

            it "should get back 200 + giver_serialized gift" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: regift_hash(receiver) }
                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.find(old_gift.id + 1)

                rrc 200
                json["status"].should == 1
                json["data"].class.should == Hash

                gift_response = json["data"]
                db_gift = new_gift
                db_gift_hsh = db_gift.giver_serialize
                db_gift_hsh.each do |key, value|
                    times = ["created_at", "updated_at", "redeemed_at"]
                    if times.include? key
                        gift_response[key].to_datetime.month.should  == value.to_datetime.month
                        gift_response[key].to_datetime.day.should    == value.to_datetime.day
                        gift_response[key].to_datetime.hour.should   == value.to_datetime.hour
                        gift_response[key].to_datetime.minute.should == value.to_datetime.minute
                    else
                        gift_response[key].should == value
                    end
                end
            end

            it "should return 404 if old gift not found" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: regift_hash(receiver) }
                post :regift, format: :json, id: 1978347, data: params

                rrc 404
            end

            context "bad request situations" do

                it "should not accept stringified receiver hash" do
                    request.env["HTTP_TKN"] = "USER_TOKEN"
                    params = { message: "New Regift Message", receiver: regift_hash(receiver).to_json }
                    post :regift, format: :json, id: old_gift.id, data: params

                    rrc 400
                end

                it "should not accept a request without a receiver hash" do
                    request.env["HTTP_TKN"] = "USER_TOKEN"
                    post :regift, format: :json, id: old_gift.id, data: {message: "New Regift Message"}

                    rrc 400
                end

                it "should not accept a request with receiver only :name" do
                    request.env["HTTP_TKN"] = "USER_TOKEN"
                    params = { message: "Bad request", receiver: {"name" => "Dont Accept"}}
                    post :regift, format: :json, id: old_gift.id, data: params

                    rrc 400
                end
            end

            it "should create a new gift with correct giver" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }
                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.last
                new_gift.giver_name.should == regifter.name
                new_gift.giver_id.should   == regifter.id
            end

            it "should create a new gift with correct receiver bug fix" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                giver.phone = "5556778899"
                giver.save
                old_gift.phone = "5556778899"
                old_gift.save
                rec_hsh = JSON.parse("{\"facebook_id\":\"690550062\",\"name\":\"Lauren Chavez\"}")
                params = { message: "Love you", receiver: rec_hsh }
                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.where(message: "Love you").first
                new_gift.receiver_name.should == "Lauren Chavez"
                new_gift.facebook_id.should   == "690550062"
                new_gift.phone.should_not     == old_gift.phone
            end

            it "should set the status of the old gift to regifted" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }
                post :regift, format: :json, id: old_gift.id, data: params
                old_gift_reloaded = Gift.find(old_gift.id)
                old_gift_reloaded.status.should == 'regifted'
            end

            it "should set the status of new gift to open" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }
                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.last
                new_gift.status.should == 'open'
            end

            it "should set the status of 'social identifier only gift' to incomplete" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                no_id_user     = FactoryGirl.build(:nobody, :id => nil )
                hsh_no_id_user = regift_hash(no_id_user)
                params = { message: "New Regift Message", receiver: hsh_no_id_user }

                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.find_by(receiver_email: no_id_user.email)
                puts new_gift.inspect
                new_gift.status.should == 'incomplete'
            end

            it "should create 'social identifier only gift'" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                no_id_user     = FactoryGirl.build(:nobody, :id => nil )
                hsh_no_id_user = regift_hash(no_id_user)
                params = { message: "New Regift Message", receiver: hsh_no_id_user }

                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.last
                new_gift.id.should == (old_gift.id + 1)
            end

            it "should reject requests with malformed data" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }
                post :regift, format: :json, id: old_gift.id, data: params, faker: "FAKE"
                rrc 400
            end

            it "should add new message to new gift" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }
                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.last
                new_gift.message.should == "New Regift Message"
            end

            it "should copy the shopping cart to new gift" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }
                post :regift, format: :json, id: old_gift.id, data: params
                new_gift = Gift.last
                new_gift.shoppingCart.should == "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]"
            end

        end

        describe "#regift security" do

            let(:old_gift)  { @gift }
            let(:giver)     { @giver }
            let(:regifter)  { @user }
            let(:receiver)  { FactoryGirl.create(:receiver) }
            let(:rec_hsh)  { regift_hash(receiver)}

            it "it should not allow regift for de-activated reGifters" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }

                regifter.update_attribute(:active, false)
                post :regift, format: :json, id: old_gift.id, data: params
                rrc(401)
            end

            it "it should not allow regift to de-activated receivers" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                params = { message: "New Regift Message", receiver: rec_hsh }
                receiver.update_attribute(:active, false)
                post :regift, format: :json, id: old_gift.id, data: params
                puts "here is json inspect #{json.inspect}"
                rrc 403
                json["status"].should == 0
                json["data"].should   == 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
            end

        end

        describe "#regift_to_socal_network_non_users" do

            before(:each) do
                @user = FactoryGirl.create :nonetwork
                @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            end

            {
                email: "jon@gmail.com",
                phone: "9173706969",
                facebook_id: "123",
                twitter: "999"
            }.stringify_keys.each do |type_of, identifier|
                it "should find user account for old #{type_of}" do
                    request.env["HTTP_TKN"] = "USER_TOKEN"

                    @user.update_attribute(type_of, identifier)
                    if (type_of == "phone") || (type_of == "email")
                        key = "receiver_#{type_of}"
                    else
                        key = type_of
                    end
                    old_gift = FactoryGirl.create :regift, { key => identifier}
                    giver    = old_gift.giver
                    recipient_data = regift_hash(@user)
                    params = { message: "New Regift Message", receiver: recipient_data }
                    post :regift, format: :json, id: old_gift.id, data: params

                    puts json.inspect
                    new_gift = Gift.find(json["data"]["gift_id"])
                    new_gift.receiver_id.should == @user.id
                end

                it "should look thru multiple unique ids for a user object with #{type_of}" do
                    request.env["HTTP_TKN"] = "USER_TOKEN"
                    @user.update_attribute(type_of, identifier)
                    old_gift = FactoryGirl.create :regift, gift_social_id_hsh
                    giver    = old_gift.giver
                    recipient_data = regift_hash(@user)
                    params = { message: "New Regift Message", receiver: recipient_data }
                    post :regift, format: :json, id: old_gift.id, data: params
                    new_gift = Gift.find(json["data"]["gift_id"])
                    new_gift.receiver_id.should == @user.id
                end

                it "should look thru not full gift of unique ids for a user object with #{type_of}" do
                    request.env["HTTP_TKN"] = "USER_TOKEN"
                    @user.update_attribute(type_of, identifier)
                    missing_hsh = gift_social_id_hsh
                    if type_of == "phone"
                        missing_hsh["receiver_email"] = ""
                    else
                        missing_hsh["receiver_phone"] = ""
                    end
                    old_gift  = FactoryGirl.create :regift, missing_hsh
                    giver     = old_gift.giver
                    recipient_data = regift_hash(@user)
                    params = { message: "New Regift Message", receiver: recipient_data }
                    post :regift, format: :json, id: old_gift.id, data: params
                    new_gift = Gift.find(json["data"]["gift_id"])
                    new_gift.receiver_id.should == @user.id
                end
            end

        end

        def regift_hash receiver
            user_data_hash = {}
            user_data_hash["receiver_id"]   = receiver.id
            user_data_hash["name"]          = receiver.name
            user_data_hash["email"]         = receiver.email
            user_data_hash["phone"]         = receiver.phone
            user_data_hash["facebook_id"]   = receiver.facebook_id
            user_data_hash["twitter"]       = receiver.twitter
            user_data_hash
        end

        def gift_social_id_hsh
            {
                receiver_email: "jon@gmail.com",
                receiver_phone: "9173706969",
                facebook_id: "123",
                twitter: "999"
            }
        end
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)


        before(:each) do
            Gift.delete_all
            User.delete_all
            UserSocial.delete_all
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
            @user.update(:remember_token => "USER_TOKEN")
            @card = FactoryGirl.create(:visa, name: @user.name, user_id: @user.id)
            @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,31.50,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

        end

        it "should correctly create and save gift to databse" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)
            # test that create gift does not create the gift or the sale
            gift = FactoryGirl.build :gift, receiver_id: @user.id, credit_card: @card, message: "Dont forget about me"
            gift.credit_card = @card.id
            gift.value = "31.50"
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: @cart
            rrc(200)
            json["status"].should == 1
            json["data"].class.should == Hash
            saved_gift = Gift.find_by(value: "31.50")
            saved_gift.message.should ==  "Dont forget about me"
        end

        it "should return 404 + 'credit card not on file' msg when card not found" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            # test that create gift does not create the gift or the sale
            gift = FactoryGirl.build :gift, receiver_id: @user.id, credit_card: @card
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: @cart
            rrc(404)
            json["status"].should == 0
            json["data"].class.should == String

            json["data"].should == 'We do not have that credit card on record.  Please choose a different card.'
        end

        it "should successfully create gift and return giver_serialized obj + 200 OK" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)
            # test that create gift does not create the gift or the sale
            gift = FactoryGirl.build :gift, receiver_id: @user.id, credit_card: @card
            gift.credit_card = @card.id
            gift.value = "31.50"
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: @cart
            rrc(200)
            json["status"].should == 1
            json["data"].class.should == Hash

            gift_response = json["data"]
            db_gift = Gift.last
            db_gift_hsh = db_gift.giver_serialize
            db_gift_hsh.each do |key, value|
                times = ["created_at", "updated_at", "redeemed_at"]
                if times.include? key
                    gift_response[key].to_datetime.month.should  == value.to_datetime.month
                    gift_response[key].to_datetime.day.should    == value.to_datetime.day
                    gift_response[key].to_datetime.hour.should   == value.to_datetime.hour
                    gift_response[key].to_datetime.minute.should == value.to_datetime.minute
                else
                    gift_response[key].should == value
                end
            end

        end

        it "should successfully create gift and return giver_serialized obj + 200 OK" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            # test that create gift does not create the gift or the sale
            gift = FactoryGirl.build :gift, { receiver_id: @user.id, credit_card: @card.id }

            post :create, format: :json, data: make_gift_json(gift) , shoppingCart: @cart
            rrc(200)
            json["status"].should == 1
            json["data"].class.should == Hash

            gift_response = json["data"]
            db_gift = Gift.last
            db_gift_hsh = db_gift.giver_serialize
            db_gift_hsh.each do |key, value|
                times = ["created_at", "updated_at", "redeemed_at"]
                if times.include? key
                    gift_response[key].to_datetime.month.should  == value.to_datetime.month
                    gift_response[key].to_datetime.day.should    == value.to_datetime.day
                    gift_response[key].to_datetime.hour.should   == value.to_datetime.hour
                    gift_response[key].to_datetime.minute.should == value.to_datetime.minute
                else
                    gift_response[key].should == value
                end
            end

        end

        it "should create incomplete gift with phone BUG FIX" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            geep = FactoryGirl.create(:gift)
            data         = {"receiver_name"=>"Stewart Christensen", "value"=>"7.00", "service"=>"0.35", "message"=>"Testing contact", "credit_card"=> @card.id, "provider_name"=>-1, "provider_id"=>geep.provider_id, "receiver_phone"=>"(702) 672-8462", "receiver_email"=>"stewart.christensen2@facebook.com"}
            shoppingCart = [{"item_id"=>240, "item_name"=>"Dogfish Head 60 Minute", "price"=>"7", "quantity"=>1}]
            post :create, format: :json, data: data, shoppingCart: shoppingCart
            rrc(200)
            json["status"].should == 1
            json["data"].class.should == Hash
            gift_id = json["data"]["gift_id"]
            gift = Gift.find(gift_id)
            gift.receiver_phone.should == "7026728462"
            gift.receiver_name.should  == "Stewart Christensen"
            gift.receiver_email.should == "stewart.christensen2@facebook.com"
            gift.status.should == 'incomplete'
            gift.pay_stat.should == 'charge_unpaid'
        end

        {
            email: "jon@gmail.com",
            phone: "9173706969",
            facebook_id: "123",
            twitter: "999"
         }.stringify_keys.each do |type_of, identifier|
            it "should find user account for old #{type_of}" do
                Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
                Sale.any_instance.stub(:resp_code).and_return(1)
                request.env["HTTP_TKN"] = "USER_TOKEN"
                @user.update_attribute(type_of, identifier)
                if (type_of == "phone") || (type_of == "email")
                    key = "receiver_#{type_of}"
                else
                    key = type_of
                end
                gift = FactoryGirl.build :gift, { key => identifier}
                gift.credit_card = @card.id
                gift.value = "31.50"
                post :create, format: :json, data: set_gift_as_sent(gift, key) , shoppingCart: @cart
                rrc(200)
                json["status"].should == 1
                json["data"].has_key?('gift_id').should be_true
                new_gift = Gift.find(json["data"]["gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru multiple unique ids for a user object with #{type_of}" do
                Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
                Sale.any_instance.stub(:resp_code).and_return(1)
                request.env["HTTP_TKN"] = "USER_TOKEN"
                # add one unique id to the user record
                @user.update_attribute(type_of, identifier)
                # create a gift with multiple new social ids

                gift = FactoryGirl.build :gift, gift_social_id_hsh
                gift.credit_card = @card.id
                gift.value = "31.50"
                post :create, format: :json, data: create_multiple_unique_gift(gift) , shoppingCart: @cart
                rrc(200)
                json["status"].should == 1
                json["data"].has_key?('gift_id').should be_true
                # check that the :action assign the user_id to receiver_id and saves the gift
                new_gift = Gift.find(json["data"]["gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru not full gift of unique ids for a user object with #{type_of}" do
                Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
                Sale.any_instance.stub(:resp_code).and_return(1)
                request.env["HTTP_TKN"] = "USER_TOKEN"
                # add one unique id to the user record
                @user.update_attribute(type_of, identifier)
                # create a gift with multiple new social ids
                missing_hsh = gift_social_id_hsh
                if type_of == "phone"
                    missing_hsh["receiver_email"] = ""
                else
                    missing_hsh["receiver_phone"] = ""
                end

                gift = FactoryGirl.build :gift, missing_hsh
                gift.credit_card = @card.id
                gift.value = "31.50"
                post :create, format: :json, data: create_multiple_unique_gift(gift, missing_hsh) , shoppingCart: @cart
                rrc(200)
                json["status"].should == 1
                json["data"].has_key?('gift_id').should be_true
                # check that the :action assign the user_id to receiver_id and saves the gift
                new_gift = Gift.find(json["data"]["gift_id"])
                new_gift.receiver_id.should == @user.id
            end
        end

        context "oauth credentials" do

            it "should make incomplete gift with new network ID oauth credentials" do
                Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
                Sale.any_instance.stub(:resp_code).and_return(1)
                provider = FactoryGirl.create :provider
                request.env["HTTP_TKN"] = "USER_TOKEN"
                gift_hsh = {}
                gift_hsh["message"]        = "I just Bought a Gift!"
                gift_hsh["receiver_name"]  = "Oauth Friend"
                gift_hsh["provider_id"]    = provider.id
                gift_hsh["giver_id"]       = @user.id
                gift_hsh["value"]          = "45.00"
                gift_hsh["service"]        = "2.25"
                gift_hsh["credit_card"]    = @card.id

                hsh =  {"token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
                gift_hsh["receiver_oauth"] = hsh

                post :create, format: :json, data: gift_hsh , shoppingCart: @cart
                rrc(200)
                json["status"].should == 1
                json["data"].has_key?('gift_id').should be_true
            end
        end

        # Git should validate total and service

        it "it should not allow gift creating for de-activated givers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"

            deactivated_user = FactoryGirl.create :user, { active: true}
            @user.update(active: false)
            # hit create gift with a receiver_id of a deactivated user
            gift = FactoryGirl.create :gift, { receiver_id: deactivated_user.id }
            # test that create gift does not create the gift or the sale
            post :create, format: :json, data: make_gift_json(gift) , shoppingCart: @cart
            rrc(401)
        end

        it "should reject requests with extra keys" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            gift = FactoryGirl.create :gift, { receiver_id: @user.id }
            post :create, format: :json, data: make_gift_json(gift) , shoppingCart: @cart, faker: "FAKE"
            rrc(400)
        end

        it "should not allow gift creating for de-activated receivers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver = FactoryGirl.create(:giver)
            giver.update(remember_token: "USER_TOKEN" )
            deactivated_user = FactoryGirl.create :receiver, { active: false}
            # hit create gift with a receiver_id of a deactivated user
            gift = FactoryGirl.create :gift, { receiver_id: deactivated_user.id }
            # test that create gift does not create the gift or the sale
            post :create, format: :json, data: make_gift_json(gift) , shoppingCart: @cart

            json["status"].should == 0
            # test that a message returns that says the user is no longer in the system , please gift to them with a non-drinkboard identifier
            json["data"].should == 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
        end

        it "should not charge the card when gift receiver is deactivated" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver = FactoryGirl.create(:giver)
            deactivated_user = FactoryGirl.create :receiver, { active: false}
            gift = FactoryGirl.build :gift, { receiver_id: deactivated_user.id }
            post :create, format: :json, data: make_gift_json(gift) , shoppingCart: @cart
            new_gift = Gift.find_by(receiver_id: deactivated_user.id)
            new_gift.should be_nil
            last = Gift.last
            last.should be_nil
        end

        it "should not allow gift creation for non-app users -- AdminGiver" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver       = FactoryGirl.create(:giver)
            admin_user  = FactoryGirl.create(:admin_user)
            receiver    = admin_user.giver
            gift        = FactoryGirl.build :gift
            gift_hsh    = make_gift_hsh(gift)
            gift_hsh["receiver_id"]   = receiver.id
            gift_hsh["receiver_name"] = receiver.name
            post :create, format: :json, data: gift_hsh , shoppingCart: @cart
            new_gift = Gift.find_by(giver_id: giver.id)
            new_gift.should be_nil
            json["status"].should == 0
            json["data"].should == "You cannot gift to the ItsOnMe Staff account"
        end

        it "should not allow gift creation for non-app users -- BizUser" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver    = FactoryGirl.create(:giver)
            provider = FactoryGirl.create(:provider)
            receiver = provider.biz_user
            gift     = FactoryGirl.build :gift
            gift_hsh = make_gift_hsh(gift)

            gift_hsh["receiver_id"]   = receiver.id
            gift_hsh["receiver_name"] = receiver.name
            post :create, format: :json, data: gift_hsh , shoppingCart: @cart
            new_gift = Gift.find_by(giver_id: giver.id)
            new_gift.should be_nil
            json["status"].should == 0
            json["data"].should == "You cannot gift to the #{provider.biz_user.name} account"
        end

        it "should create gift for user with last name 'Staff'" do
            request.env["HTTP_TKN"] = "OTHERTOKEN"
            giver = FactoryGirl.create(:giver)
            @user = giver
            giver.update(remember_token: "OTHERTOKEN")
            @card = FactoryGirl.create(:card, :name => @user.name, :user_id => @user.id)
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,31.50,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

            receiver = FactoryGirl.create(:receiver, last_name: "Staff")
            gift     = FactoryGirl.build :gift
            gift.credit_card = @card.id
            gift.value = "31.50"
            gift_hsh = make_gift_hsh(gift)
            gift_hsh["receiver_id"]   = receiver.id
            gift_hsh["receiver_name"] = receiver.name

            post :create, format: :json, data: gift_hsh , shoppingCart: @cart
            new_gift = Gift.find_by(giver_id: giver.id)
            new_gift.receiver.should == receiver
            json["status"].should == 1
        end

        it "should return 'that credit_card does not exist' when cant find credit card" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver = FactoryGirl.create(:giver)
            receiver = FactoryGirl.create(:receiver)
            gift = FactoryGirl.build :gift, { receiver_id: receiver.id }
            gift.add_receiver receiver
            gift.credit_card = "999999"
            post :create, format: :json, data: make_gift_json(gift) , shoppingCart: @cart
            rrc(404)
            json["status"].should == 0
            json["data"].should   == "We do not have that credit card on record.  Please choose a different card."
        end

        it "should accept stringified JSON'd 'gift" do
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)
            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver = FactoryGirl.create(:giver)
            receiver = FactoryGirl.create(:receiver)
            gift = FactoryGirl.build :gift
            gift.credit_card = @card.id
            gift.value = "31.50"
            gift.add_receiver receiver
            post :create, format: :json, data: make_gift_json(gift) , shoppingCart: @cart
            rrc(200)
            json["status"].should == 1
        end

        it "should accept non-stringified JSON gift" do
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)

            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver = FactoryGirl.create(:giver)
            receiver = FactoryGirl.create(:receiver)
            gift = FactoryGirl.build(:gift, credit_card: @card.id)
            gift.add_receiver receiver
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: @cart
            rrc(200)
        end

        it "should return 400 if gift and shoppingCart are not hash - stringified and non-stringified" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            giver    = FactoryGirl.create(:giver)
            receiver = FactoryGirl.create(:receiver)
            gift     = FactoryGirl.build :gift, { receiver_id: receiver.id }
            gift.add_receiver receiver
            post :create, format: :json, data: "this is not a hash" , shoppingCart: @cart
            rrc(400)
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: "this is not a hash"
            rrc(400)
            post :create, format: :json, data: [make_gift_hsh(gift)] , shoppingCart: @cart
            rrc(400)
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: { "item_name" => "no good"}
            rrc(400)
            post :create, format: :json, data: nil , shoppingCart: @cart
            rrc(400)
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: nil
            rrc(400)
            post :create, format: :json, shoppingCart: @cart
            rrc(400)
            post :create, format: :json, data: make_gift_hsh(gift)
            rrc(400)
        end

        it "should accept joe meek's JSON" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            Gift.delete_all
            @provider = Provider.last || FactoryGirl.create(:provider)
            req_json= {"gift"=>{"receiver_name"=>"Jon Guty", "twitter" => "23874628734",  "value"=>"20.00", "service"=>"1.00", "message"=>"4 ass juices. Shopping cart total changed to value", "credit_card"=> @card.id, "provider_id"=> @provider.id , "provider_name"=>"Double Down Saloon"}, "shoppingCart"=>[{"item_id"=>257, "item_name"=>"Ass Juice", "price"=>"5", "quantity"=>4}]}
            data = req_json["gift"]
            sc = req_json["shoppingCart"]
            post :create, format: :json, data: data , shoppingCart: sc
            rrc(200)
            json["status"].should == 1
        end

        it "gifts should have correct values/costs" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)
            gift = FactoryGirl.build :gift, receiver_id: @user.id, value: "100", service: "5"
            gift.credit_card = @card.id
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: @cart
            rrc(200)
            gift = Gift.last
            gift.service.should == "5.00"
            gift.value.should == "100"
            gift.cost.should  == "85.0"
        end

        def make_gift_json gift
            make_gift_hsh(gift).to_json
        end

        def make_gift_hsh gift
            {
                giver_id:       @user.id,
                giver_name:     @user.name,
                value:          gift.value,
                service:        gift.service,
                receiver_id:    gift.receiver_id,
                receiver_name:  gift.receiver_name,
                message:        gift.message,
                provider_id:    gift.provider.id,
                credit_card:    gift.credit_card
            }
        end

        def gift_social_id_hsh
            {
                receiver_email: "jon@gmail.com",
                receiver_phone: "9173706969",
                facebook_id: "123",
                twitter: "999"
            }
        end

        def create_multiple_unique_gift gift, missing_hsh=nil
            missing_hsh ||= gift_social_id_hsh
            {
                value:          gift.value,
                service:        gift.service,
                receiver_name:  gift.receiver_name,
                provider_id:    gift.provider.id,
                credit_card:    gift.credit_card
            }.merge(missing_hsh).to_json
        end

        def set_gift_as_sent gift, key
            {
                key => gift.send(key),
                value:          gift.value,
                service:        gift.service,
                receiver_name:  gift.receiver_name,
                provider_id:    gift.provider.id,
                credit_card:    gift.credit_card
            }.to_json
        end
    end
end
