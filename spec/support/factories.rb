FactoryGirl.define do

    factory :user do
        first_name "jon"
        password   "specspec"
        password_confirmation "specspec"
        sequence(:email)            { |n| "ronny#{n}@gmail.com" }
        sequence(:remember_token)   { |n| "token#{n}" }
        sequence(:facebook_id)      { |n| "98a#{n}fd332" }
        sequence(:twitter)          { |n| "283s#{n}f6fd3" }
        sequence(:phone) do
            phone = ""
            10.times do
              phone + (2..8).to_a.sample.to_s
            end
            phone
        end

        factory :giver do
            sequence(:first_name) { |n|  "jonGifter#{n}" }
        end

        factory :receiver do
            sequence(:first_name) { |n|  "ronReceiver#{n}" }
        end
    end



    factory :provider do
        sequence(:name)    { |n|    "ichizos#{n}" }
        city        "New York"
        address     "123 happy st"
        zip         "11211"
        state       "NY"
        sequence(:token)   { |n| "token#{n}" }
        zinger      "its amazing"
        description "get all the japanese culinary delights that are so hard to find in America"
        sequence(:phone) do
            phone = ""
            10.times do
              phone += (2..8).to_a.sample.to_s
            end
            phone
        end
    end

    # factory :city_provider do
    #     city "New York"
    #     providers_array
    # end

    factory :user_social do
        user_id     1
        type_of     "email"
        identifier  "example@gmail.com"
    end

    factory :gift do
        giver_id        13
        giver_name      "henry"
        receiver_name   "jon"
        provider { FactoryGirl.create(:provider)}
        total           "100"
        service         "4"
        credit_card     4567890
        shoppingCart    "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]"
    end

    factory :order_no_association_gift, class: "Gift" do
        giver_id        13
        giver_name      "henry"
        receiver_name   "jon"
        provider { FactoryGirl.create(:provider)}
        total           "100"
        service         "4"
        credit_card     4567890
        shoppingCart    "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]"
    end

    factory :sale do
        giver_id    1
        gift_id     1
        resp_code   1
        response    AuthResponse.new
        transaction AuthTransaction.new
    end

    factory :order do |order|
        order.redeem      { FactoryGirl.create(:redeem)}
        order.gift        { |order| order.redeem.gift }
        order.provider    { |order| order.redeem.gift.provider }
        server_code "jg"
    end

    factory :order_no_associations , class: "Order" do |id|
        gift_id    id
        redeem_id  1
        provider_id 1
        server_code  "jg"
    end

    factory :redeem do
        gift    { FactoryGirl.create(:gift)}

    end

end