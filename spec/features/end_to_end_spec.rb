require 'spec_helper'

# original gift creation
# user 1 log in
# get cities / gets merchant / then picks menu / then chooses friend email  out of contacts / selects credit card / pays
# user 2 receives email / clicks on link to do to mobile site / creates account / gift is in gift center / goes to merchant / redeems drink / sends thank you to user 1

describe "Happy Path" do
    before do
        Capybara.current_driver = :selenium
    end



    it "should send and redeem gift thru email for to a non-user" do

        stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
        stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})

        json = post_form_data '/app/create_account.json', :data => { :email => 'test@gmail.com', first_name: "Jon", last_name: "Leprechaun",password: 'secret', password_confirmation: 'secret' }
        user_id = json['success']['user_id']
        r_token = json['success']['token']
        cities = get '/app/cities_no.json'
        run_delayed_jobs
        WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
            b = JSON.parse(req.body);
            link = b["message"]["merge_vars"].first["vars"].first["content"];

            link.match(/account\/confirmemail/) }
        # puts Capybara.current_session.driver.rack_server.port
        puts cities.inspect
        city_name = cities.first["name"]
        city_name.should == "Las Vegas"
        provider  = FactoryGirl.create(:provider, city: 'Las Vegas')
        FactoryGirl.create(:menu_string, provider_id: provider.id)
        json = post_form_data '/app/providers.json', :data => { token: r_token, city: city_name }

        provider_id = json.first["provider_id"]

        menu = post_form_data '/app/menu_v2.json', :data => provider_id
        puts menu.inspect
        item = menu.first["items"].first
        item["quantity"] = 3
        price = item["price"]
        total = price.to_i * 3
        service = total * 0.05

        shoppingCart = [item].to_json

        json = post_form_data '/app/buy_gift', gift: { total: total, service: service, receiver_name: "Neil Sarkar", receiver_email: "neil@gmail.com", provider_id: provider_id}, shoppingCart: shoppingCart, token: r_token
        puts json.inspect
        gift_id = json["success"]["Gift_id"]
        gift_id.should_not be_blank
        abs_gift_id = gift_id + NUMBER_ID

        WebMock.reset!
        stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
        run_delayed_jobs
        WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
            puts req.body;
            b = JSON.parse(req.body);
            if b["template_name"] == "iom-gift-notify-receiver"
                link = b["message"]["merge_vars"].first["vars"].first["content"];
                link.match(/signup\/acceptgift\/#{abs_gift_id}/)
            else
                true
            end

        }.twice

        json = post_form_data '/app/create_account.json', :data => { :email => "neil@gmail.com", first_name: "Neil", password: 'secret', password_confirmation: 'secret' }
        user_id = json['success']['user_id']
        r_token = json['success']['token']
        json = post_form_data '/app/update',  token: r_token
        json["success"]["badge"].should == 1
        gift = json["success"]["gifts"].first
        gift["giver_name"].should == "Jon Leprechaun"
        gift["status"].should == "open"

        json = post_form_data '/app/redeem.json', token: r_token, data: gift["gift_id"]
        redeem_code = json["success"]
        redeem_code.should_not be_blank

        json = post_form_data '/app/order_confirm', token: r_token, data: gift["gift_id"], server_code: "jjjj"

        json["success"]["total"].should == total.to_s + ".00"
        json["success"]["server"].should == "jjjj"
        json["success"]["order_number"].should_not be_blank

    end





end