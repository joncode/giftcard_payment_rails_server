require 'spec_helper'

describe Web::V3::GiftsController do

    before(:each) do
        User.delete_all
        Gift.delete_all
    	@user     = FactoryGirl.create :user, iphone_photo: "d|myphoto.jpg"
    	@receiver = FactoryGirl.create :user, first_name: "bob", iphone_photo: "d|myphoto2.jpg"
        other1    = FactoryGirl.create :user, iphone_photo: "d|myphoto2.jpg"
    	other2    = FactoryGirl.create :user, iphone_photo: "d|myphoto2.jpg"
        @provider = FactoryGirl.create :provider
    	3.times { FactoryGirl.create :gift, giver: other1, receiver_name: @user.name, receiver_id: @user.id, provider: @provider}
    	3.times { FactoryGirl.create :gift, giver: @user, receiver_name: other2.name, receiver_id: other2.id, provider: @provider}
    	3.times { FactoryGirl.create :gift, giver: other1, receiver_name: other2.name, receiver_id: other2.id, provider: @provider}
    end

    describe :index do
        it_should_behave_like("client-token authenticated", :post, :create)

        it "should return the correct gifts for the user" do
            request.headers["HTTP_X_AUTH_TOKEN"] = @user.remember_token
            get :index, format: :json
            rrc(200)
            json["data"].count.should == 6
            keys = [ "created_at", "giv_name", "giv_photo", "giv_id", "giv_type", "rec_id", "rec_name", "rec_photo", "items", "value", "status", "expires_at", "cat", "msg", "loc_id", "loc_name", "loc_phone", "loc_address", "gift_id"]
            compare_keys(json["data"][0], keys)
        end

    end

    describe :create do
        it_should_behave_like("client-token authenticated", :post, :create)
        before do
            @user.update(:remember_token => "USER_TOKEN")
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
                "gift_id" => new_gift.id
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