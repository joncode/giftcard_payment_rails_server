require 'spec_helper'

include UserSessionFactory
include MocksAndStubs

describe Web::V3::GiftsController do

    before(:each) do
        User.delete_all
        Gift.delete_all
    	@user     = FactoryGirl.create :user, iphone_photo: "d|myphoto.jpg"
    	@receiver = FactoryGirl.create :user, first_name: "bob", iphone_photo: "d|myphoto2.jpg"
        @other1    = FactoryGirl.create :user, iphone_photo: "d|myphoto2.jpg"
    	other2    = FactoryGirl.create :user, iphone_photo: "d|myphoto2.jpg"
        @provider = FactoryGirl.create :provider
    	3.times { FactoryGirl.create :gift, giver: @other1, receiver_name: @user.name, receiver_id: @user.id, provider: @provider}
    	3.times { FactoryGirl.create :gift, giver: @user, receiver_name: other2.name, receiver_id: other2.id, provider: @provider}
    	3.times { FactoryGirl.create :gift, giver: @other1, receiver_name: other2.name, receiver_id: other2.id, provider: @provider}
    end

    describe :index do
        it_should_behave_like("client-token authenticated", :post, :create)

        it "should return the correct gifts for the user" do
            request.headers["HTTP_X_AUTH_TOKEN"] = @user.remember_token
            get :index, format: :json
            rrc(200)
            json["data"].count.should == 6
            keys = ["r_sys", "created_at", "giv_name", "giv_photo", "giv_id", "giv_type", "rec_id", "rec_name", "rec_photo", "items", "value", "status", "expires_at", "cat", "msg", "loc_id", "loc_name", "loc_phone", "loc_address", "gift_id"]
            compare_keys(json["data"][0], keys)
        end

        it "should return the gifts of another user" do
            request.headers["HTTP_X_AUTH_TOKEN"] = @user.remember_token
            get :index, format: :json, user_id: @other1.id
            rrc(200)
            json["data"].count.should == 6
            data = json["data"]
            data.first["giv_id"].should == @other1.id
        end

        it "should return 404 when other use is not found" do
            request.headers["HTTP_X_AUTH_TOKEN"] = @user.remember_token
            get :index, format: :json, user_id: 10000
            rrc(404)

        end
    end

    describe :create do
        it_should_behave_like("client-token authenticated", :post, :create)

        before do
            @user = create_user_with_token "USER_TOKEN", @user
            @card = FactoryGirl.create(:visa, name: @user.name, user_id: @user.id)
            @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,31.50,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
        end

        it "should create a gift" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)
            gift = FactoryGirl.build :gift, receiver_id: @receiver.id, receiver_name: "bob", credit_card: @card, message: "Dont forget about me", provider_id: @provider.id
            gift_hash = make_gift_hsh(gift)
            gift.credit_card = @card.id
            gift.value = "31.50"
            post :create, format: :json, data: gift_hash
            rrc(200)
            new_gift = Gift.last
            json["status"].should == 1
            json["data"].class.should == Hash
            json["data"].should == {
                "created_at" => new_gift.created_at.to_json.gsub("\"", ""),
                "giv_name" => "Jimmy Basic",
                "giv_photo" => "d|myphoto.jpg",
                "giv_id" => @user.id,
                "giv_type" => "User",
                "rec_name" => "bob",
                "items" => [{"detail"=>nil, "price"=>13, "quantity"=>1, "item_id"=>82, "item_name"=>"Original Margarita "}],
                "value" => new_gift.value,
                "status" => "incomplete",
                "cat" => 300,
                "msg" => "hope you enjoy it!",
                "loc_id" => @provider.id,
                "loc_name" => @provider.name,
                "loc_phone" => @provider.phone,
                "loc_address" => @provider.complete_address,
                "gift_id" => new_gift.id,
                "r_sys" => 2
            }
        end

        it "should return correct error message on failure" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)
            gift = FactoryGirl.build :gift, receiver_id: @receiver.id, receiver_name: "bob", credit_card: @card, message: "Dont forget about me", provider_id: @provider.id
            gift_hash = make_gift_hsh_fail(gift)
            gift.credit_card = @card.id
            gift.value = "31.50"
            post :create, format: :json, data: gift_hash
            rrc(200)
            json["status"].should == 0
            json["err"].should == "INVALID_INPUT"
            json["msg"].should == "Gift could not be created"
            json["data"].should == [
                { "name" => "receiver email", "msg" => "is invalid" }
            ]
        end

        it "should return correct error messages when gift sale returns a string" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            Sale.any_instance.stub(:auth_capture).and_return(AuthResponse.new)
            Sale.any_instance.stub(:resp_code).and_return(1)
            @receiver.update(active: false)
            gift = FactoryGirl.build :gift, receiver_id: @receiver.id, receiver_name: "bob", credit_card: @card, message: "Dont forget about me", provider_id: @provider.id
            gift_hash = make_gift_hsh(gift)
            gift_hash["rec_net"] = "io"
            gift_hash["rec_net_id"] = @receiver.id
            gift.credit_card = @card.id
            gift.value = "31.50"
            post :create, format: :json, data: gift_hash
            rrc(200)
            json["status"].should == 0
            json["err"].should == "INVALID_INPUT"
            json["msg"].should == "Gift could not be created"
            json["data"].should == ["User is no longer in the system , please gift to them with phone, email, facebook, or twitter"]
        end
    end

    describe :read do
        it_should_behave_like("client-token authenticated", :patch, :read, id: 1)

        before(:each) do
            @user = create_user_with_token "USER_TOKEN", @user
            @gift = FactoryGirl.create(:gift, receiver_id: @user.id, receiver_name: @user.username)
        end

        it "should notify an open gift" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.status.should == 'open'
            patch :read, format: :json, id: @gift.id
            @gift.reload.status.should == 'notified'
            @gift.token.should be_nil
        end

        it "should send a 'your gift is opened' push to the gift giver" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            test_urban_airship_gift_opened(@gift) do
                patch :read, format: :json, id: @gift.id
            end
        end

    end

    describe :notify do
        it_should_behave_like("client-token authenticated", :patch, :notify, id: 1)

        before(:each) do
            @user = create_user_with_token "USER_TOKEN", @user
            @gift = FactoryGirl.create(:gift, receiver_id: @user.id, receiver_name: @user.username)
        end

        it "should notify an open gift" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.status.should == 'open'
            patch :notify, format: :json, id: @gift.id
            @gift.reload.status.should == 'notified'
        end

        it "should return token when gift is currently notified" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.notify
            patch :notify, format: :json, id: @gift.id
            rrc(200)
            json["status"].should               == 1
            json["data"]["token"].should        == @gift.token
            json["data"]["new_token_at"].should == @gift.new_token_at.xmlschema
            json["data"]["notified_at"].should  == @gift.notified_at.xmlschema

        end

        it "should send fail msg when an incomplete gift" do
            incomplete_gift                  = FactoryGirl.create(:gift)
            incomplete_gift.status.should    == 'incomplete'
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            patch :notify, format: :json, id: incomplete_gift.id
            rrc(200)
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{incomplete_gift.token} at #{incomplete_gift.provider_name} cannot be redeemed"
        end

        it "should send fail msg gift is un-redeemable [expired, regifted, cancelled] " do
            @gift.update(status: 'regifted', pay_stat: "charge_regifted", redeemed_at: Time.now.utc)

            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            patch :notify, format: :json, id: @gift.id
            rrc(200)
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{@gift.token} at #{@gift.provider_name} cannot be redeemed"
        end

        it "should send fail msg gift already redeemed" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.notify
            @gift.redeem_gift
            patch :notify, format: :json, id: @gift.id
            rrc(200)
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{@gift.token} at #{@gift.provider_name} has already been redeemed"

        end

        it "should return 404 if gift is not found" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            patch :notify, format: :json, id: 12412412
            rrc(404)
        end

        it "should not allow opening gifts that user does not receive" do
            other_user = FactoryGirl.create(:user)
            other_gift = FactoryGirl.create(:gift, receiver_id: other_user.id)
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            patch :notify, format: :json, id: other_gift.id
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{other_gift.token} at #{other_gift.provider_name} cannot be redeemed"
        end
    end

    describe :redeem do
        it_should_behave_like("client-token authenticated", :put, :redeem, id: 1)

        before(:each) do
            @user = create_user_with_token "USER_TOKEN", @user
            @gift = FactoryGirl.create(:gift, receiver_id: @user.id, receiver_name: @user.username)
            @gift.notify
        end

        it "should redeem a notifed gift" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.status.should == 'notified'
            @gift.redeemed_at.should be_nil
            patch :redeem, format: :json, id: @gift.id
            rrc(200)
            json["status"].should == 1
            json["data"]["token"].should        == @gift.token
            json["data"]["new_token_at"].should == @gift.new_token_at.xmlschema
            json["data"]["notified_at"].should  == @gift.notified_at.xmlschema
            @gift.reload.status.should == 'redeemed'
            @gift.redeemed_at.should_not be_nil
        end

        it "should redeem a notifed gift with server initials" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.status.should == 'notified'
            @gift.redeemed_at.should be_nil
            patch :redeem, format: :json, id: @gift.id, data: {"server" => "2342" }
            rrc(200)
            @gift.reload
            @gift.status.should == 'redeemed'
            @gift.server.should == '2342'
            @gift.redeemed_at.should_not be_nil
        end

        it "should return 404 if gift is not found" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            patch :redeem, format: :json, id: 1234211
            rrc(404)
        end

        it "should send fail msg when an incomplete / open gift" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            other_gift = FactoryGirl.create(:gift, receiver_email: @user.email)
            patch :redeem, format: :json, id: other_gift.id
            rrc(200)
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{other_gift.token} at #{other_gift.provider_name} cannot be redeemed"
        end

        it "should send fail msg gift already redeemed" do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.redeem_gift
            patch :redeem, format: :json, id: @gift.id
            rrc(200)
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{@gift.token} at #{@gift.provider_name} has already been redeemed"
        end

        it "should send fail msg gift is un-redeemable [expired, regifted, cancelled] " do
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            @gift.update(status: 'regifted', pay_stat: "charge_regifted", redeemed_at: Time.now.utc)
            patch :redeem, format: :json, id: @gift.id
            rrc(200)
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{@gift.token} at #{@gift.provider_name} cannot be redeemed"
        end

        it "should not allow opening gifts that user does not receive" do
            other_user = FactoryGirl.create(:user)
            other_gift = FactoryGirl.create(:gift, receiver_id: other_user.id)
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            patch :redeem, format: :json, id: other_gift.id
            json["status"].should == 0
            json["err"].should    ==  "NOT_REDEEMABLE"
            json["msg"].should == "Gift #{other_gift.token} at #{other_gift.provider_name} cannot be redeemed"
        end
    end
end

def make_gift_hsh gift
    {
        rec_net: "em",
        rec_net_id: gift.receiver_email,
        rec_name: gift.receiver_name,
        msg: "hope you enjoy it!",
        cat: 300,
        items: JSON.parse(gift.shoppingCart),
        value: gift.value,
        service: gift.service,
        loc_id: gift.provider_id,
        pay_id: @card.id
    }
end

def make_gift_hsh_fail gift
    {
        rec_net: "em",
        rec_net_id: "bademailatemaildotcom",
        rec_name: gift.receiver_name,
        msg: "hope you enjoy it!",
        cat: 300,
        items: JSON.parse(gift.shoppingCart),
        value: gift.value,
        service: gift.service,
        loc_id: gift.provider_id,
        pay_id: @card.id
    }
end