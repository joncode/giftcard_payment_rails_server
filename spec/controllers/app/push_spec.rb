require 'spec_helper'

describe AppController do

# user sends themselves a gift
# user receives a gift push notification
# push notification updates the bage to the wrong levels
# user then goes into app and gets the correct badge level

    it "should create gift for self using old API - should send push notification to UrbanAirship with correct badge - should send badge update to phone with correct badge - should send the push notification first - receiver email second - giver invoice third" do
        ResqueSpec.reset!
        Provider.delete_all
        User.delete_all

        User.any_instance.stub(:init_confirm_email).and_return(true)
        User.any_instance.stub(:persist_social_data).and_return(true)
        RegisterPushJob.stub(:perform).and_return(true)
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:perform).and_return(true)


        user_hsh = { twitter: "875818226", email: "ta@ta.com", phone: "2052920036", first_name: "Addis", last_name: "Dev"}
        provider_hsh = { name: "Artifice", token: "Specialpushtoken" }
        provider = FactoryGirl.create(:provider, provider_hsh)

        user = FactoryGirl.create(:user, user_hsh)
        @user = user
        pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
        pnt      = PnToken.create(user_id: user.id, pn_token: pn_token)
        user.phone.should == "2052920036"
        provider.name.should == "Artifice"
        pnt.reload
        pnt.pn_token.should == "FAKE_PN_TOKENFAKE_PN_TOKEN"
        pnt.user_id.should  == user.id
        params = "{  \"month\" : \"10\",  \"number\" : \"5465280044607690\",  \"user_id\" : #{user.id},  \"brand\" : \"MasterCard\",  \"name\" : \"Addis Dev\",  \"year\" : \"2015\",  \"csv\" : \"333\",  \"nickname\" : \"Jj\"}"

        post :add_card, format: :json, token: user.remember_token, data: params
        card = Card.find_by(nickname: "Jj")
        card.user_id.should == user.id
        run_delayed_jobs
        params = "{  \"twitter\" : \"875818226\",  \"receiver_email\" : \"ta@ta.com\",  \"receiver_phone\" : \"2052920036\",  \"giver_name\" : \"Addis Dev\",  \"service\" : 1,  \"total\" : 20,  \"provider_id\" : #{provider.id},  \"receiver_id\" : #{user.id},  \"message\" : \"\",  \"credit_card\" : #{card.id},  \"provider_name\" : \"Artifice\",  \"receiver_name\" : \"Addis Dev\",  \"giver_id\" : #{user.id}}"
        cart   = "[{\"detail\":\"Draft\",\"price\":7,\"item_name\":\"Dogfish Head 60 Minute\",\"item_id\":240,\"quantity\":2},{\"detail\":\"Draft\",\"price\":6,\"item_name\":\"Downtown Brown\",\"item_id\":241,\"quantity\":1}]"
        auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,20.00,CC,credit,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
        stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

        post :create_gift, format: :json, gift: params , origin: "d", shoppingCart: cart , token: user.remember_token

        gift = user.sent.where(provider_id: provider.id ).first
        gift.twitter.should == "875818226"

        post :relays, format: :json, token: user.remember_token
        json["success"]["badge"].should == 1
        user_alias = pnt.ua_alias
        good_push_hsh = {:aliases =>["#{user_alias}"],:aps =>{:alert => "#{gift.giver_name} sent you a gift at #{provider.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1,:android=>{:alert=>"#{gift.giver_name} sent you a gift at #{provider.name}!"}}
        Urbanairship.should_receive(:push).with(good_push_hsh)
        run_delayed_jobs
    end

end

