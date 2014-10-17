require 'spec_helper'

describe AppController do

    before(:each) do
        User.delete_all
        Gift.delete_all
        Provider.delete_all
        Brand.delete_all
    end

    let(:user) { FactoryGirl.create(:user) }

    describe "relays" do

        let(:giver)     { FactoryGirl.create(:giver) }
        let(:receiver)  { FactoryGirl.create(:receiver) }

        before(:each) do

            @number = 10
            @number.times do |n|
                gift =  FactoryGirl.build(:gift)
                gift.add_giver(giver)
                gift.add_receiver(receiver)
                gift.save
            end
        end

        it "should return a correct badge count" do
            post :relays, format: :json, token: receiver.remember_token
            json["success"]["badge"].should == @number
        end

        it "should return gifts with deactivated givers" do
            giver.update_attribute(:active, false)
            post :relays, format: :json, token: receiver.remember_token
            json["success"]["badge"].should == @number
        end

        it "should not return gifts with deactivated receivers" do
            receiver.update_attribute(:active, false)
            post :relays, format: :json, token: receiver.remember_token
            json["error"].should == {"user"=>"could not identity app user"}
        end

        it "should not return gifts that are unpaid" do
            gs = Gift.all
            total_changed = 0
            skip_first = false
            skip_second = false
            gs.each do |gift|
                if gift.id.even? && skip_first && skip_second
                    gift.update(pay_stat: "payment_error")
                    total_changed += 1

                end
            end
            post :relays, format: :json, token: receiver.remember_token
            json["success"]["badge"].should == (@number - total_changed)
        end

        it "should return shopping cart as an array not a json string" do
            post :relays, format: :json, token: receiver.remember_token
            gifts_ary = json["success"]["gifts"]
            gifts_ary[0]["shoppingCart"].class.should == Array
            gifts_ary[0]["shoppingCart"][0].class.should == Hash
        end

        context "scope out unpaid gifts / expired gifts" do

            it "should not return :pay_stat => 'payment_error' gifts" do
                gifts = Gift.all.to_a
                last_gift = gifts.pop
                gifts.each do |gift|
                    gift.update(pay_stat: "payment_error" )
                end

                post :relays, format: :json, token: receiver.remember_token
                json["success"]["badge"].should == 1
            end

            it "should not return :status => 'expired' gifts" do
                gifts = Gift.all.to_a
                last_gift = gifts.pop
                last_gift = gifts.pop
                gifts.each do |gift|
                    gift.update(status: "expired")
                end
                post :relays, format: :json, token: receiver.remember_token
                json["success"]["badge"].should == 2
            end
        end

        it "should send gifts when providers are paused / not live / deactivated" do
            gift = Gift.find_by(giver_id: giver)
            provider = gift.provider
            provider.deactivate

            post :relays, format: :json, token: receiver.remember_token
            json["success"]["badge"].should == @number
        end

    end

    describe "drinkboard_users" do

        #let(:user) { FactoryGirl.create(:user) }
        let(:deactivated) { FactoryGirl.create(:user, active: false ) }


        it "should return array of drinkboard users" do
            post :drinkboard_users, format: :json, token: user.remember_token
            response.status.should == 200
            json.class.should      == Array
        end

        it "should return users from deactivated user" do
            post :drinkboard_users, format: :json, token: deactivated.remember_token
            response.status.should == 200
            puts "JSON --->>>  #{json}"
            #json["error"].should == "cannot find user from token"
            json.class.should == Array
        end

    end

    describe :update_user do

        #let(:user) { FactoryGirl.create(:user) }

        context "authorization" do

            it "should not allow unauthenticated access" do
                post :update_user, format: :json, token: "No_Entrance"
                rrc_old(200)
                json["error"].should   == "App needs to be reset. Please log out and log back in."
            end

        end

        it "should require a update_user hash" do
            post :update_user, format: :json, token: user.remember_token, data: "update_userd data"
            json["error"].should   == "App needs to be reset. Please log out and log back in."
            post :update_user, format: :json, token: user.remember_token, data: nil
            json["error"].should   == "App needs to be reset. Please log out and log back in."
            post :update_user, format: :json, token: user.remember_token
            json["error"].should   == "App needs to be reset. Please log out and log back in."
        end

        it "should return user hash when success" do
            post :update_user, format: :json, token: user.remember_token, data: { "first_name" => "Steve"}
            rrc_old(200)
            json["success"].class.should  == Hash
        end

        it "should return validation errors" do
            post :update_user, format: :json, token: user.remember_token, data: { "email" => "" }
            json["error_server"].class.should    == Hash
            json["error_server"]["email"].should == "is invalid"
        end

        {
            first_name: "Ray",
            last_name:  "Davies",
            email: "ray@davies.com",
            phone: "5877437859",
            birthday: "10/10/1971",
            sex: "female",
            zip: "85733",
            phone: "(702) 410-9605",
            twitter: "300231203",
            facebook_id: "92734034901"
        }.stringify_keys.each do |type_of, value|

            it "should update the user #{type_of} in database" do
                post :update_user, format: :json, token: user.remember_token, data: { type_of => value }
                new_user = user.reload
                value = "7024109605" if value == "(702) 410-9605"
                new_user.send(type_of).should == value
            end
        end

        it "should not update attributes that dont exist and succeed" do
            hsh = { "house" => "chill" }
            post :update_user, format: :json, token: user.remember_token, data: hsh
            json["success"].class.should  == Hash
        end

        it "should not update attributes that  are not allowed and succeed" do
            hsh = { "password" => "doNOTallow", "remember_token" => "DO_NOT_ALLOW" }
            post :update_user, format: :json, token: user.remember_token, data: hsh
            json["success"].class.should  == Hash
        end
    end

    describe :brands do

        before(:each) do

            20.times do |index|
                name = "Chicag#{index}"
                FactoryGirl.create(:brand, name: name)
            end
            brand = Brand.first
            brand.update_attribute(:active, false)
            @user =  FactoryGirl.create(:user)
        end

        it "should return a list of all active brands serialized when success" do
            post :brands, format: :json, token: user.remember_token
            rrc_old(200)
            ary = json
            ary.class.should == Array
            ary.count.should == 19
            hsh = ary.first
            keys = ["name", "next_view", "brand_id", "photo"]
            compare_keys(hsh, keys)
        end

    end

    describe :brand_merchants do

        before(:each) do
            Brand.delete_all
            @brand = FactoryGirl.create(:brand, name: "Green Bay Packers")
            20.times do |index|
                if index.even?
                    FactoryGirl.create(:provider, brand_id: @brand.id)
                else
                    FactoryGirl.create(:provider, building_id: @brand.id)
                end
            end
            provider = Provider.last
            provider.update_attribute(:active, false)
        end

        it "should return a list of providers" do
            amount  = Provider.where(active: true).count
            keys    =  ["city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live", "zinger", "desc"]
            post :brand_merchants, format: :json, data: @brand.id, token: user.remember_token
            rrc_old(200)
            ary = json
            ary.class.should == Array
            ary.count.should == amount
            hsh = ary.first
            compare_keys(hsh, keys)
        end
    end

    describe :providers do
        it "should return a list of all active providers serialized when success" do
            20.times do
                FactoryGirl.create(:provider)
            end
            Provider.last.update_attribute(:active, false)
            post :providers, format: :json, token: user.remember_token
            keys =  ["city", "latitude", "longitude", "name", "phone", "provider_id", "photo", "full_address", "live","zinger", "desc"]
            rrc_old(200)
            ary = json
            ary.class.should == Array
            ary.count.should == 19
            hsh = ary.first
            compare_keys(hsh, keys)
        end

        context "should return a list of active providers outside city but in region" do
            it "using region id" do
                FactoryGirl.create(:provider, name: "Abe's", city: "San Diego", region_id: 3)
                FactoryGirl.create(:provider, name: "Bob's", city: "La Jolla", region_id: 3)
                FactoryGirl.create(:provider, name: "Cam's", city: "New York", region_id: 2)
                post :providers, format: :json, token: user.remember_token, city: "3"
                rrc_old(200)
                ary = json
                ary.class.should == Array
                ary.count.should == 2
                ary[0]["name"].should == ("Abe's")
                ary[1]["name"].should == ("Bob's")
            end

            it "using region name" do
                FactoryGirl.create(:provider, name: "Abe's", city: "San Diego", region_id: 3)
                FactoryGirl.create(:provider, name: "Bob's", city: "La Jolla", region_id: 3)
                FactoryGirl.create(:provider, name: "Cam's", city: "New York", region_id: 2)
                post :providers, format: :json, token: user.remember_token, city: "San Diego"
                rrc_old(200)
                ary = json
                ary.class.should == Array
                ary.count.should == 2
                ary[0]["name"].should == ("Abe's")
                ary[1]["name"].should == ("Bob's")
            end
        end
    end

    describe :menu_v2 do

        before(:each) do
            @provider = FactoryGirl.create(:provider)
            FactoryGirl.create(:menu_string, provider_id: @provider.id)
        end

        it "should return the provider menu in version 2 format only" do
            post :menu_v2, format: :json, token: user.remember_token, data: @provider.id
            rrc_old(200)
            menu_json = json
            menu_json.class.should == Array
            # menu = JSON.parse menu_json
            # keys = ["section", "items"]
            # menu.class.should == Array
            # compare_keys(menu[0], keys)
        end
    end

    describe :get_settings do
        it "should get the users settings and return json" do
            post :get_settings, format: :json, token: user.remember_token
            keys    =  ["email_follow_up", "email_invite", "email_invoice", "email_receiver_new", "email_redeem", "user_id", "email_reminder_gift_receiver", "email_reminder_gift_giver"]
            rrc_old(200)
            hsh = json["success"]
            hsh.class.should == Hash
            compare_keys(hsh, keys)
        end
    end

    describe :save_settings do

        it "should receive json'd settings and update the record" do
            post :save_settings, format: :json, token: user.remember_token, data: "{  \"email_receiver_new\" : \"false\",  \"email_invite\" : \"false\",  \"email_redeem\" : \"false\",  \"email_invoice\" : \"false\",  \"email_follow_up\" : \"false\"}"
            rrc_old(200)
            json["success"].should        == "Settings saved"
            setting = user.setting
            setting.reload
            setting.email_invoice.should be_false
            setting.email_redeem.should be_false
            setting.email_invite.should be_false
            setting.email_follow_up.should be_false
            setting.email_receiver_new.should be_false
        end
    end

    describe :get_cards do

        it "should return a list of cards for the user" do
            FactoryGirl.create(:card, user_id: user.id)
            FactoryGirl.create(:amex, user_id: user.id)
            FactoryGirl.create(:visa, user_id: user.id)
            FactoryGirl.create(:mastercard, user_id: user.id)

            post :get_cards, format: :json, token: user.remember_token
            rrc_old(200)
            json["success"].class.should  == Array
            json["success"].count.should  == 4
        end

        it "should return an empty array if user has no cards" do
            post :get_cards, format: :json, token: user.remember_token
            rrc_old(200)
            json["success"].class.should  == Array
            json["success"].count.should  == 0
        end
    end

    describe :add_card do

        it "should accept json'd hash of require fields and return 'add' with card ID" do
            params = "{\"month\":\"02\",\"number\":\"4417121029961508\",\"user_id\":772,\"name\":\"Hiromi Tsuboi\",\"year\":\"2016\",\"csv\":\"910\",\"nickname\":\"Dango\"}"

            post :add_card, format: :json, token: user.remember_token, data: params

            card = Card.find_by(user_id: 772)
            json["add"].should == card.id
        end

        it "should not save incomplete card info" do
            params = "{\"number\":\"4417121029961508\",\"user_id\":772,\"name\":\"Hiromi Tsuboi\",\"year\":\"2016\",\"csv\":\"910\",\"nickname\":\"Dango\"}"

            post :add_card, format: :json, token: user.remember_token, data: params

            card = Card.find_by(user_id: 772)
            json["error_server"].class.should == Hash
            json["error_server"].has_key?('month').should be_true
        end
    end

    describe :delete_card do

        it "should return card id in delete key on success" do
            card = FactoryGirl.create(:card, user_id: user.id)
            post :delete_card, format: :json, token: user.remember_token, data: card.id
            rrc_old(200)
            json["delete"].should == card.id.to_s
        end

        it "should delete the card from the database" do
            card = FactoryGirl.create(:card, user_id: user.id)
            post :delete_card, format: :json, token: user.remember_token, data: card.id
            card = Card.where(user_id: user.id).count
            card.should == 0
        end

        it "should return 404 with no ID or wrong ID" do
            card = FactoryGirl.create(:card, user_id: user.id)
            post :delete_card, format: :json, token: user.remember_token
            rrc_old(404)
            card = FactoryGirl.create(:card, user_id: user.id)
            post :delete_card, format: :json, token: user.remember_token, data: 928312
            rrc_old(404)
        end

        it "should delete the card from Auth.net" do
            card = FactoryGirl.create(:card, user_id: user.id, cim_token: "27634232")
            user.update("cim_profile" => "826735482")
             stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
                     with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<deleteCustomerPaymentProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <customerProfileId>826735482</customerProfileId>\n  <customerPaymentProfileId>27634232</customerPaymentProfileId>\n</deleteCustomerPaymentProfileRequest>\n",
                          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
                     to_return(:status => 200, :body => "", :headers => {})
            post :delete_card, format: :json, token: user.remember_token, data: card.id
            rrc_old(200)

            WebMock.should have_requested(:post, "https://apitest.authorize.net/xml/v1/request.api").once
        end
    end

    describe :create_redeem do

        let(:giver)     { FactoryGirl.create(:giver) }
        let(:receiver)  { FactoryGirl.create(:receiver) }

        it "should return the redeem code on success" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            post :create_redeem, format: :json, token: receiver.remember_token, data: gift.id
            gift.reload
            json["success"].should == gift.token.to_s
        end

        it "should not allow redeems created for  gifts where user is not receiver" do
            other = FactoryGirl.create(:user)
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(other)
            gift.save
            post :create_redeem, format: :json, token: receiver.remember_token, data: gift.id
            json['error_server'].should == "Gift not found"
        end

        it "should send a 'your gift is opened' push to the gift giver" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            ResqueSpec.reset!
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            @gift = gift
            badge = Gift.get_notifications(@gift.giver)
            user_alias = @gift.giver.ua_alias
            good_push_hsh = {:aliases =>["#{user_alias}"],:aps =>{:alert => "#{@gift.receiver_name} opened your gift at #{@gift.provider_name}!",:badge=>badge,:sound=>"pn.wav"},:alert_type=>2,:android =>{:alert => "#{@gift.receiver_name} opened your gift at #{@gift.provider_name}!"}}

            Urbanairship.should_receive(:push).with(good_push_hsh)

            post :create_redeem, format: :json, token: receiver.remember_token, data: gift.id
            run_delayed_jobs
        end
    end

    describe :create_order do

        let(:giver)     { FactoryGirl.create(:giver) }
        let(:receiver)  { FactoryGirl.create(:receiver) }

        it "should create an order for the gift" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            gift.notify
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            gift.reload
            gift.server == "test"
            gift.redeemed_at.should_not be_nil
            gift.order_num.should_not be_nil
        end

        it "should return order_number, server, and total on success" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            gift.notify
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            json["success"] == gift.token.to_s
        end

        it "should update gift server_code, redeemed_at" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            time = Time.now
            gift.notify
            gift.redeemed_at.should be_nil
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            gift.reload
            gift.status.should == 'redeemed'
            gift.server.should == "test"
            gift.redeemed_at.utc.day.should == time.utc.day
        end

        it "should return validation errors on bad gift" do
            gift =  FactoryGirl.build(:gift, status: 'notified')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            json["error_server"].should == {"Data Transfer Error"=>"Gift #{gift.id} cannot be redeemed"}
        end

        it "should return data transfer error if gift not found" do
            gift =  FactoryGirl.build(:gift, status: 'notified')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            post :create_order, format: :json, token: receiver.remember_token, data: 0, server_code: "test"
            json["error_server"].should == {"Data Transfer Error"=>"Please Reload Gift Center"}
        end

        it "should not allow creating orders for gifts where user is not reciepient" do
            other = FactoryGirl.create(:user)
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(other)
            gift.save
            gift.notify
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            json['error_server'].should == {'Data Transfer Error'=>'Please Reload Gift Center'}
        end
    end

    describe :archive do

        let(:giver)     { FactoryGirl.create(:giver) }
        let(:receiver)  { FactoryGirl.create(:receiver) }

        before(:each) do

            @number_received = 9
            @number_received.times do |n|
                gift =  FactoryGirl.build(:gift)
                gift.add_giver(giver)
                gift.add_receiver(receiver)
                gift.save
            end

            @number_sent = 12
            @number_sent.times do |n|
                gift =  FactoryGirl.build(:gift)
                gift.add_giver(receiver)
                gift.add_receiver(giver)
                gift.save
            end
        end

        it "should send a list of sent gifts" do
            post :archive, format: :json, token: receiver.remember_token
            json["sent"].class.should == Array
            json["sent"].count.should == @number_sent
        end

        it "should send sent gifts (purchaser) with giver keys" do
            keys = ["created_at", "id", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "status", "total", "updated_at", "shoppingCart", "receiver_photo", "giver_photo", "provider_photo", "provider_phone", "city", "sales_tax", "live", "latitude", "longitude", "provider_address", "time_ago", "gift_id", "redeem_code"]
            post :archive, format: :json, token: receiver.remember_token
            gift_hsh = json["sent"][0]
            compare_keys(gift_hsh, keys)
        end

        it "should send a list of used gifts" do
            gs = Gift.where(receiver_id: receiver.id)
            gs.each do |gift|
                gift.notify
                gift.reload
                gift.redeem_gift( "xyz")
            end
            post :archive, format: :json, token: receiver.remember_token
            json["used"].class.should == Array
            json["used"].count.should == @number_received
        end

        it "should send used gifts with receiver keys" do
            gs = Gift.where(receiver_id: receiver.id)
            gs.each do |gift|
                gift.notify
                gift.reload
                gift.redeem_gift( "xyz")
            end
            keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "sales_tax", "live", "latitude", "longitude", "provider_address", "time_ago", "gift_id", "updated_at", "created_at", "redeem_code"]
            post :archive, format: :json, token: receiver.remember_token
            gift_hsh = json["used"][0]
            compare_keys(gift_hsh, keys)
        end

        it "should send empty arrays when no gifts" do
            Gift.delete_all
            post :archive, format: :json, token: receiver.remember_token
            json["sent"].class.should == Array
            json["sent"].count.should == 0
            json["used"].class.should == Array
            json["used"].count.should == 0
        end
    end

    describe :others_questions do

        before(:each) do
            qs = [["Day Drinking", "Night Drinking"], ["Red Wine", "White Wine"], ["White Liqours", "Brown Liqours"], ["Straw", "No straw"], ["Light Beer", "Dark Beer"], ["Mimosa", "Bloody Mary"], ["Rare", "Well Done"], ["City Vacation", "Beach Vacation"], ["Shaken", "Stirred"], ["Rocks", "Neat"], ["Sweet", "Sour"], ["Steak", "Fish"]]
            qs.each do |q|
                Question.create(left: q[0], right: q[1])
            end
        end

        let(:receiver)  { FactoryGirl.create(:receiver) }

        it "should get the app users questions" do
            post :others_questions, format: :json, token: receiver.remember_token, user_id: receiver.id
            rrc_old(200)
            json.class.should == Array
            question = json.first
            keys = ["left", "right", "question_id"]
            # ANSWER KEY IS LEFT OFF CAUSE ITS OPTIONAL
            compare_keys(question, keys)
        end
    end

    describe :questions do

        before(:each) do
            qs = [["Day Drinking", "Night Drinking"], ["Red Wine", "White Wine"], ["White Liqours", "Brown Liqours"], ["Straw", "No straw"], ["Light Beer", "Dark Beer"], ["Mimosa", "Bloody Mary"], ["Rare", "Well Done"], ["City Vacation", "Beach Vacation"], ["Shaken", "Stirred"], ["Rocks", "Neat"], ["Sweet", "Sour"], ["Steak", "Fish"]]
            qs.each do |q|
                Question.create(left: q[0], right: q[1])
            end
        end

        let(:receiver)  { FactoryGirl.create(:receiver) }

        it "should get the app users questions" do
            post :questions, format: :json, token: receiver.remember_token
            rrc_old(200)
            json.class.should == Array
            question = json.first
            keys = ["left", "right", "question_id"]
            # ANSWER KEY IS LEFT OFF CAUSE ITS OPTIONAL
            compare_keys(question, keys)
        end

        it "should update requests with answers" do
            q1 = Question.find_by(left: "Day Drinking")
            q2 = Question.find_by(left: "Red Wine")
            q3 = Question.find_by(left: "White Liqours")
            q4 = Question.find_by(left: "Straw")
            q5 = Question.find_by(left: "Light Beer")
            q6 = Question.find_by(left: "Mimosa")
            q7 = Question.find_by(left: "Rare")

            params = "[  {    \"question_id\" : #{q1.id},    \"left\" : \"Day Drinking\",    \"answer\" : \"0\",    \"right\" : \"Night Drinking\"  },  {    \"question_id\" : #{q2.id},    \"left\" : \"Red Wine\",    \"answer\" : \"1\",    \"right\" : \"White Wine\"  },  {    \"question_id\" : #{q3.id},    \"left\" : \"White Liqours\",    \"answer\" : \"0\",    \"right\" : \"Brown Liqours\"  },  {    \"question_id\" : #{q4.id},    \"left\" : \"Straw\",    \"answer\" : \"0\",    \"right\" : \"No straw\"  },  {    \"question_id\" : #{q5.id},    \"left\" : \"Light Beer\",    \"answer\" : \"0\",    \"right\" : \"Dark Beer\"  },  {    \"question_id\" : #{q6.id},    \"left\" : \"Mimosa\",    \"answer\" : \"0\",    \"right\" : \"Bloody Mary\"  },  {    \"question_id\" : #{q7.id},    \"left\" : \"Rare\",    \"answer\" : \"1\",    \"right\" : \"Well Done\"  }]"

            post :questions, format: :json, token: receiver.remember_token, answers: params
            rrc_old(200)
            json.class.should == Array
            question = json.first
            keys = ["left", "right", "question_id", "answer"]
            compare_keys(question, keys)
        end
    end

    describe :reset_password do

        before do
            @receiver = FactoryGirl.create(:receiver, email: "findme@gmail.com")
            ResqueSpec.reset!
        end



        it "should send success response for screen" do
            post :reset_password, format: :json, email: @receiver.email
            rrc_old(200)
            json["success"].should == "Email is Sent , check your inbox"
        end

        it "should update the user reset password token and expiration" do
            post :reset_password, format: :json, email: @receiver.email
            rrc_old(200)
            @receiver.reload
            @receiver.reset_token.should_not be_nil
            @receiver.reset_token_sent_at.utc.hour.should == Time.now.utc.hour
        end

        it "should return error message if email doesn not exist" do
            post :reset_password, format: :json, email: "non-existant@yahoo.com"
            rrc_old(200)
            json["error"].should == "We do not have record of that email"
        end

        it "should send the reset password email" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            post :reset_password, format: :json, email: @receiver.email
            run_delayed_jobs
            email_link = "#{PUBLIC_URL}/account/resetpassword/#{@receiver.reset_token}"
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-reset-password"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/#{email_link}/)
                else
                    true
                end

            }.once
        end
    end
end
