require 'spec_helper'

describe "Connections Feature" do

    before do
        Capybara.current_driver = :selenium
    end

    it "should allow admin tools to reconcile missed gift <-> new user connection via facebook" do
        # set up the giver account

        giver = FactoryGirl.create(:user, first_name: "Brittany", last_name: "Houston")
        giver_id = giver.id
        r_token = giver.remember_token
        @card = FactoryGirl.create(:visa, user_id: giver_id)
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,31.50,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})



        # gift sent to receiver via facebook
        gift = "{  \"giver_name\" : \"Brittany Houston \",  \"message\" : \"Hey CP! Download this app, we can send eachother drinks! Here's a beer for next time were at Artifice. Xo\",  \"provider_name\" : \"Artifice\",  \"giver_id\" : #{giver_id},  \"total\" : 7,  \"service\" : 0.35,  \"credit_card\" : #{@card.id},  \"provider_id\" : 106,  \"receiver_name\" : \"Christie Parker\",  \"facebook_id\" : \"100005220484939\"}"
        origin = "f"
        shoppingCart = "[{\"detail\":\"Draft\",\"price\":7,\"item_name\":\"Dogfish Head 60 Minute\",\"item_id\":124,\"quantity\":1}]"
        json = post_form_data '/app/buy_gift', gift: gift, origin: origin, shoppingCart: shoppingCart, token: r_token

        gift = Gift.find_by(giver_id: giver.id)
        gift.facebook_id.should == "100005220484939"

        # receiver creates account without facebook id
        data = "{  \"first_name\" : \"Christie\",  \"use_photo\" : \"ios\",  \"password\" : \"password\",  \"last_name\" : \"Parker\",  \"phone\" : \"7025237365\",  \"email\" : \"Christie.parker@gmail.com\",  \"origin\" : \"d\",  \"iphone_photo\" : \"http:\\/\\/res.cloudinary.com\\/htaaxtzcv\\/image\\/upload\\/v1361898825\\/ezsucdxfcc7iwrztkags.jpg\",  \"password_confirmation\" : \"password\"}"
        pnt  = "d6d0b8e325f6bf692699d83cebecf8d313d73d2cf738f9c482820a4bab47c7f7"
        json = post_form_data '/app/create_account.json', :data => data, :pn_token => pnt, token: GENERAL_TOKEN

        user = User.find_by(email: "christie.parker@gmail.com")
        user.first_name.should == "Christie"
        puts "------------------------------------"
        # admin tools to add missing user data (from gift) to user account
        # admin tools associates gift with user account
        json = post_form_data "/admt/v2/gifts/#{gift.id}/add_receiver", :data => user.id
        puts json.inspect
        user.reload
        gift.reload
        #user.facebook_id.should == "100005220484939"
        gift.receiver_id.should == user.id
    end

end

# <Gift id: 1, giver_name: "Brittany Houston", receiver_name: "Christie Parker",
# provider_name: "Artifice", giver_id: 1, receiver_id: nil, total: nil, credit_card: "1",
# provider_id: 106, message: "Hey CP! Download this app, we can send eachother dr...",
# status: "incomplete", created_at: "2013-12-09 18:20:16", updated_at: "2013-12-09 18:20:16",
# receiver_phone: nil, tax: nil, tip: nil, regift_id: nil, foursquare_id: nil,
# facebook_id: "100005220484939", anon_id: nil, sale_id: nil, receiver_email: nil,
# shoppingCart: "[{\"detail\":\"Draft\",\"price\":7,\"item_name\":\"Dogfish H...",
# twitter: nil, service: "0.35", order_num: nil, cat: 0, active: true, pay_stat: "charge_unpaid",
# pay_type: nil, pay_id: nil, redeemed_at: nil, server: nil, payable_id: 1, payable_type: "Sale", giver_type: "User", value: "7">

# <User id: 2, email: "christie.parker@gmail.com", admin: false, password_digest: "$2a$04$NJckSLYf2nEb3Nkmoj2y3uWKul/zMTZkjyIM7gjlJACQ...",
# remember_token: "gn_ZeQZQuS5U-5bS-HkEaw", created_at: "2013-12-09 18:21:42", updated_at: "2013-12-09 18:21:42",
# address: nil, address_2: nil, city: nil, state: nil, zip: nil, credit_number: nil, phone: "7025237365",
# first_name: "Christie", last_name: "Parker", facebook_id: nil, handle: nil, server_code: nil, twitter: nil,
# active: true, persona: "", foursquare_id: nil, facebook_access_token: nil, facebook_expiry: nil,
# foursquare_access_token: nil, sex: nil, is_public: nil, facebook_auth_checkin: nil,
# iphone_photo: "http://res.cloudinary.com/htaaxtzcv/image/upload/v1...", reset_token_sent_at: nil,
# reset_token: nil, birthday: nil, origin: nil, confirm: "00", perm_deactive: false>



# Gift
#     :receiver_id

# User
#     :facebook_id






















