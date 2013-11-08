require 'spec_helper'

describe Mdot::V2::GiftsController do

    describe :archive do
        it_should_behave_like("token authenticated", :get, :archive)

        before(:each) do
            UserSocial.delete_all
            User.delete_all
            Provider.delete_all
            @user = FactoryGirl.create(:user, email: "badge@gmail.com", twitter: "123", facebook_id: "7982364", active: true)
            @user.update_attribute(:remember_token, "USER_TOKEN"       )
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
            keys = ["created_at", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "status", "total", "updated_at", "shoppingCart", "receiver_photo", "provider_photo", "provider_phone", "city", "live", "latitude", "longitude", "provider_address", "gift_id"]
            post :archive, format: :json
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

    end

    describe :badge do
        it_should_behave_like("token authenticated", :get, :badge)

        before(:all) do
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
            response.response_code.should == 401
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

        it "should return shopping cart as a json string" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :badge, format: :json
            gifts_ary = json["data"]["gifts"]
            gifts_ary[0]["shoppingCart"].class.should == String
        end

        context "scope out unpaid gifts" do

            it "should not return :pay_stat => 'declined' gifts" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                gifts = Gift.where(receiver_id: @user.id)
                gifts.each do |gift|
                    gift.update_attribute(:pay_stat ,"declined" )
                end
                last_gift = gifts.last
                last_gift.update_attribute(:pay_stat, 'charged')
                get :badge, format: :json
                json["data"]["badge"].should == 1
            end

            it "should not return :pay_stat => 'unpaid' gifts" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                gifts = Gift.where(receiver_id: @user.id)
                gifts.each do |gift|
                    gift.update_attribute(:pay_stat ,"unpaid" )
                end
                last_gift = gifts.last
                last_gift.update_attribute(:pay_stat, 'charged')
                get :badge, format: :json
                json["data"]["badge"].should == 1
            end

            it "should not return :pay_stat => 'duplicate' gifts" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                gifts = Gift.where(receiver_id: @user.id)
                gifts.each do |gift|
                    gift.update_attribute(:pay_stat ,"duplicate" )
                end
                last_gift = gifts.last
                last_gift.update_attribute(:pay_stat, 'charged')
                get :badge, format: :json
                json["data"]["badge"].should == 1
            end

        end

    end

    describe :open do
        it_should_behave_like("token authenticated", :post, :open, id: 1)

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
        end

        it "should create a redeem for the gift" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            response.response_code.should == 200
            redeem = @gift.redeem
            redeem.class.should == Redeem
        end

        it "should return the redeem code on success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            response.response_code.should == 200
            json["status"].should == 1
            json["data"].should == @gift.redeem.redeem_code
        end

        it "should change the gift status to 'notified'" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: @gift.id
            @gift.reload
            response.response_code.should == 200
            @gift.status.should == 'notified'
        end

        xit "should return validation errors if validation fail" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            json["status"].should == 0
        end

        it "should return 404 if gift id not found" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :open, format: :json, id: 0
            response.response_code.should == 404
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
            response.response_code.should == 200
            json["status"].should == 1
            json["data"]["order_number"].should == order.make_order_num
            json["data"]["total"].should        == @gift.total
            json["data"]["server"].should       == "test"
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
            redeem = Redeem.find_by_gift_id(@gift.id)
            redeem.destroy
            post :redeem, format: :json, id: @gift.id, server: "test"
            response.response_code.should == 200
            json["status"].should == 0
            json["data"].should   == {"gift_id"=>["can't be blank"], "redeem_id"=>["can't be blank"], "provider_id"=>["can't be blank"]}
        end

        it "should return data transfer error if @gift not found" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :redeem, format: :json, id: 0, server: "test"
            response.response_code.should == 404
        end
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :regift do
        it_should_behave_like("token authenticated", :post, :regift, id: 1)

    end

end
