require 'spec_helper'

describe Mdot::V2::GiftsController do

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :regift do
        it_should_behave_like("token authenticated", :post, :regift, id: 1)

    end

    describe :archive do
        it_should_behave_like("token authenticated", :get, :archive)

    end

    describe :badge do
        it_should_behave_like("token authenticated", :get, :badge)

        before(:all) do
            UserSocial.delete_all
            User.delete_all
            Provider.delete_all
            @user = FactoryGirl.create(:user, email: "badge@gmail.com", twitter: "123", facebook_id: "7982364", active: true)
            @user.update_attribute(:remember_token, "TokenGood")
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
            request.env["HTTP_TKN"] = "TokenGood"
            get :badge, format: :json
            json["status"].should == 1
            json["data"]["badge"].should  == @number
        end

        it "should return gifts with deactivated givers" do
            request.env["HTTP_TKN"] = "TokenGood"
            @giver.update_attribute(:active, false)
            get :badge, format: :json
            json["status"].should == 1
            json["data"]["badge"].should  == @number
        end

        it "should not return gifts with deactivated receivers" do
            request.env["HTTP_TKN"] = "TokenGood"
            @user.update_attribute(:active, false)
            get :badge, format: :json
            response.response_code.should == 401
        end

        it "should not return gifts that are unpaid" do
            request.env["HTTP_TKN"] = "TokenGood"
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
            keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "provider_address", "gift_id", "updated_at", "created_at"]
            request.env["HTTP_TKN"] = "TokenGood"
            get :badge, format: :json
            json_gifts = json["data"]["gifts"]
            json_gifts.class.should == Array
            serialized_gift = json_gifts[0]
            keys.each do |key|
                serialized_gift.has_key?(key).should be_true
            end
        end

        it "should return shopping cart as a json string" do
            request.env["HTTP_TKN"] = "TokenGood"
            get :badge, format: :json
            gifts_ary = json["data"]["gifts"]
            #gifts_ary[0]["shoppingCart"].class.should == Array
            #gifts_ary[0]["shoppingCart"][0].class.should == Hash
            gifts_ary[0]["shoppingCart"].class.should == String
        end

        context "scope out unpaid gifts" do

            it "should not return :pay_stat => 'declined' gifts" do
                request.env["HTTP_TKN"] = "TokenGood"
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
                request.env["HTTP_TKN"] = "TokenGood"
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
                request.env["HTTP_TKN"] = "TokenGood"
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

    describe :transactions do
        it_should_behave_like("token authenticated", :get, :transactions)

    end

    describe :open do
        it_should_behave_like("token authenticated", :post, :open, id: 1)

        it "should create a redeem for the gift" do

        end

        it "should change the gift status to notified" do

        end

        it "should return " do

        end

    end

    describe :redeem do
        it_should_behave_like("token authenticated", :post, :redeem, id: 1)

    end



end
