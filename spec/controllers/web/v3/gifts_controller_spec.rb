require 'spec_helper'

describe Web::V3::GiftsController do

    before(:each) do
    	@user     = FactoryGirl.create :user
    	other1    = FactoryGirl.create :user
    	other2    = FactoryGirl.create :user
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
            gift = FactoryGirl.build :gift, receiver_id: @user.id, receiver_name: "bob", credit_card: @card, message: "Dont forget about me"
            gift_hash = make_gift_hsh(gift)
            gift.credit_card = @card.id
            gift.value = "31.50"
            post :create, format: :json, data: make_gift_hsh(gift) , shoppingCart: @cart
            rrc(200)
            json["status"].should == 1
            json["data"].class.should == Hash
            saved_gift = Gift.find_by(value: "31.50")
            saved_gift.message.should ==  "hope you enjoy it!"
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