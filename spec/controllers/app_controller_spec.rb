require 'spec_helper'

describe AppController do

    before(:each) do
        User.delete_all
        Gift.delete_all
        Provider.delete_all
        Brand.delete_all
    end

    let(:user) { FactoryGirl.create(:user) }

    describe :relays do

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
                    gift.update_attribute(:pay_stat, "unpaid")
                    total_changed += 1
                else
                    gift.update_attribute(:pay_stat, "charged")
                    if skip_first
                        skip_second = true
                    end
                    skip_first = true
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

        context "scope out unpaid gifts" do

            it "should not return :pay_stat => 'declined' gifts" do
                gifts = Gift.all
                gifts.each do |gift|
                    gift.update_attribute(:pay_stat ,"declined" )
                end
                last_gift = gifts.last
                last_gift.update_attribute(:pay_stat, 'charged')
                post :relays, format: :json, token: receiver.remember_token
                json["success"]["badge"].should == 1
            end

            it "should not return :pay_stat => 'unpaid' gifts" do
                gifts = Gift.all
                gifts.each do |gift|
                    gift.update_attribute(:pay_stat ,"unpaid" )
                end
                last_gift = gifts.last
                last_gift.update_attribute(:pay_stat, 'charged')
                post :relays, format: :json, token: receiver.remember_token
                json["success"]["badge"].should == 1
            end

            it "should not return :pay_stat => 'duplicate' gifts" do
                gifts = Gift.all
                gifts.each do |gift|
                    gift.update_attribute(:pay_stat ,"duplicate" )
                end
                last_gift = gifts.last
                last_gift.update_attribute(:pay_stat, 'charged')
                post :relays, format: :json, token: receiver.remember_token
                json["success"]["badge"].should == 1
            end

        end

    end

    describe :drinkboard_users do

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
                response.response_code.should == 200
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
            response.response_code.should == 200
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
            phone: "(702) 410-9605"
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
            response.response_code.should == 200
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
            keys    =  ["city", "latitude", "longitude", "name", "phone", "sales_tax", "provider_id", "photo", "full_address", "live"]
            post :brand_merchants, format: :json, data: @brand.id, token: user.remember_token
            response.response_code.should == 200
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
            keys    =  ["city", "latitude", "longitude", "name", "phone", "sales_tax", "provider_id", "photo", "full_address", "live"]
            response.response_code.should == 200
            ary = json
            ary.class.should == Array
            ary.count.should == 19
            hsh = ary.first
            compare_keys(hsh, keys)
        end
    end

    describe :get_settings do
        it "should get the users settings and return json" do
            post :get_settings, format: :json, token: user.remember_token
            keys    =  ["email_follow_up", "email_invite", "email_invoice", "email_receiver_new", "email_redeem", "user_id"]
            response.response_code.should == 200
            hsh = json["success"]
            hsh.class.should == Hash
            compare_keys(hsh, keys)
        end
    end

    describe :get_cards do

        it "should return a list of cards for the user" do
            4.times do
                FactoryGirl.create(:card, user_id: user.id)
            end

            post :get_cards, format: :json, token: user.remember_token
            response.response_code.should == 200
            json["success"].class.should  == Array
            json["success"].count.should  == 4
        end

        it " should return an empty array if user has no cards" do

        end
    end

    describe :create_redeem do

        let(:giver)     { FactoryGirl.create(:giver) }
        let(:receiver)  { FactoryGirl.create(:receiver) }

        it "should create a redeem for the gift" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            post :create_redeem, format: :json, token: receiver.remember_token, data: gift.id
            gift.redeem.class.should == Redeem
        end

        it "should return the redeem code on success" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            post :create_redeem, format: :json, token: receiver.remember_token, data: gift.id
            json["success"].should == gift.redeem.redeem_code
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
            redeem = Redeem.find_or_create_with_gift(gift)
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            gift.order.class.should == Order
            gift.order.server_code.should == "test"
        end

        it "should return order_number, server, and total on success" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            redeem = Redeem.find_or_create_with_gift(gift)
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            order = gift.order
            json["success"]["order_number"].should == order.make_order_num
            json["success"]["total"].should        == gift.total
            json["success"]["server"].should       == "test"
        end

        it "should update gift server_code, redeemed_at" do
            gift =  FactoryGirl.build(:gift, status: 'open')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            redeem = Redeem.find_or_create_with_gift(gift)
            time = Time.now
            gift.redeemed_at.should be_nil
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            gift.reload
            gift.status.should == 'redeemed'
            gift.server.should == "test"
            gift.redeemed_at.day.should == time.day
        end

        it "should return validation errors on bad gift" do
            gift =  FactoryGirl.build(:gift, status: 'notified')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            post :create_order, format: :json, token: receiver.remember_token, data: gift.id, server_code: "test"
            json["error_server"].should == {"gift_id"=>"can't be blank", "redeem_id"=>"can't be blank", "provider_id"=>"can't be blank"}
        end

        it "should return data transfer error if gift not found" do
            gift =  FactoryGirl.build(:gift, status: 'notified')
            gift.add_giver(giver)
            gift.add_receiver(receiver)
            gift.save
            post :create_order, format: :json, token: receiver.remember_token, data: 0, server_code: "test"
            json["error_server"].should == {"Data Transfer Error"=>"Please Reload Gift Center"}
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
                redeem = Redeem.find_or_create_with_gift(gift)
                gift.reload
                order  = Order.init_with_gift(gift, "xyz")
                order.save
            end
            post :archive, format: :json, token: receiver.remember_token
            json["used"].class.should == Array
            json["used"].count.should == @number_received
        end

        it "should send used gifts with receiver keys" do
            gs = Gift.where(receiver_id: receiver.id)
            gs.each do |gift|
                redeem = Redeem.find_or_create_with_gift(gift)
                gift.reload
                order  = Order.init_with_gift(gift, "xyz")
                order.save
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
end












