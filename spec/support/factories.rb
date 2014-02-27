FactoryGirl.define do
    
    factory :user do
        first_name                  "Jimmy"
        last_name                   "Basic"
        password                    "specspec"
        password_confirmation       "specspec"
        sequence(:email)            { |n| "thisguy#{n}@gmail.com" }
        sequence(:remember_token)   { |n| "token#{n}" }
        sequence(:facebook_id)      { |n| "98a#{n}fd332" }
        sequence(:twitter)          { |n| "283s#{n}f6fd3" }
        sequence(:phone) do
            phone = ""
            10.times do
              phone += (2..8).to_a.sample.to_s
            end
            phone
        end

        factory :giver do
            first_name   "Jon"
            last_name    "Gifter"
        end

        factory :regifter do
            first_name   "Will"
            last_name    "ReGifter"
        end

        factory :receiver do
            first_name   "Ron"
            last_name    "Receiver"
        end
    end

    factory :nobody, :class => 'User' do
        first_name                  "No"
        last_name                   "One"
        password                    "specspec"
        password_confirmation       "specspec"
        sequence(:email)            { |n| "noone#{n}@gmail.com" }
        sequence(:remember_token)   { |n| "nope#{n}" }
        sequence(:facebook_id)      { |n| "8ssa#{n}fd332" }
        sequence(:twitter)          { |n| "28sdd3s#{n}f6fd3" }
    end

    factory :simple_user, :class => 'User' do
        first_name                  "Simple"
        last_name                   "User"
        password                    "specspec"
        password_confirmation       "specspec"
        sequence(:email)            { |n| "simple#{n}@gmail.com" }
    end

    factory :nonetwork, :class => 'User' do
        first_name                  "None"
        last_name                   "Networks"
        password                    "specspec"
        password_confirmation       "specspec"
        sequence(:email)            { |n| "nonetwork#{n}@gmail.com" }
        sequence(:remember_token)   { |n| "nonet#{n}" }
        facebook_id      nil
        twitter          nil
        phone            nil
    end

    factory :provider do
        sequence(:name)    { |n| "ichizos#{n}" }
        city        "New York"
        address     "123 happy st"
        zip         "11211"
        state       "NY"
        sequence(:token)   { |n| "tokens#{n}" }
        zinger      "its amazing"
        description "get all the japanese culinary delights that are so hard to find in America"
        sequence(:phone) do
            phone = ""
            10.times do
              phone += (2..8).to_a.sample.to_s
            end
            phone
        end

        factory :paused do
            paused   true
        end

        factory :live do
            live     true
            paused   false
        end

        factory :coming_soon do
            live     false
            paused   false
        end

    end

    factory :menu_string do
        provider_id   1
        menu          "[{\"section\":\"Signature\",\"items\":[{\"detail\":\"PATRON CITRONGE, MUDDLED JALAPENOS\",\"price\":\"15\",\"item_id\":73,\"item_name\":\"JALAPENO MARGARITA\"},{\"detail\":\"AKVINTA VODKA, REGATTA GINGER BEER, LIME JUICE, SUGAR\",\"price\":\"15\",\"item_id\":72,\"item_name\":\"Moscow Mule \"}]},{\"section\":\"Beer\",\"items\":[{\"detail\":\"\",\"price\":\"8.00\",\"item_id\":98,\"item_name\":\"Corona\"},{\"detail\":\"\",\"price\":\"7.00\",\"item_id\":97,\"item_name\":\"Bud Light\"},{\"detail\":\"\",\"price\":\"8.00\",\"item_id\":99,\"item_name\":\"Stella\"},{\"detail\":\"\",\"price\":\"8.00\",\"item_id\":100,\"item_name\":\"Beck's\"}]},{\"section\":\"Cocktail\",\"items\":[{\"detail\":\"ABSOLUT ORIENT APPLE, GINGER BEER, GINGER ALE, LEMON WEDGE\",\"price\":\"15\",\"item_id\":74,\"item_name\":\"GINGER ROGERS\"},{\"detail\":\"KETEL ONE VODKA, SODA, LIME JUICE, SIMPLE SYRUP, LIME WEDGE\",\"price\":\"15\",\"item_id\":75,\"item_name\":\"KETEL ONE FIZZ\"},{\"detail\":\"CIROC PEACH, MUDDLED RASPBERRIES FRESH LIME JUICE, SOUR \\u0026 CRANBERRY JUICE\",\"price\":\"15\",\"item_id\":76,\"item_name\":\"PINK STARBURST\"}]}]"
        data          "[]"
    end

    factory :user_social do
        user_id     1
        type_of     "email"
        sequence(:identifier)  { |n| "noone#{n}@gmail.com" }
    end

    factory :gift do |gift|
        gift.giver           { FactoryGirl.create(:giver) }
        gift.giver_name      "Jon giver"
        gift.receiver_name   "Someone New"
        gift.receiver_email   "somebody@gmail.com"
        gift.provider        { FactoryGirl.create(:provider) }
        gift.value           "100"
        gift.service         "4"
        gift.credit_card     { FactoryGirl.create(:visa).id }
        gift.shoppingCart    "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]"
        gift.message         "Factory Message"
        gift.pay_stat       "charged"
        gift.payable       { FactoryGirl.create(:sale)}

        factory :regift do |regift|
            regift.giver        { FactoryGirl.create(:giver) }
            regift.giver_name   "Jon giver"
            regift.receiver     { FactoryGirl.create(:regifter) }
            regift.receiver_name "Will Regifter"

        end

    end

    factory :gift_item do |gi|
        gi.menu_id    1
        gi.price      "10"
        gi.quantity   1
        gi.name       "Beer"
    end

    factory :gift_no_association, :class => 'Gift' do
        giver_id           10
        giver_name         "Plain Jane"
        receiver_name      "Plain Receipient"
        receiver_email     "plain@jaone.com"
        provider_id        10
        total           "100"
        service         "4"
        pay_stat        "charged"
        credit_card     4567890
        shoppingCart    "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]"
        payable           { FactoryGirl.create(:sale)}

        factory :gift_no_association_wtih_card do
            credit_card { FactoryGirl.create(:card)}
        end
    end

    factory :card do
        csv   "434"
        month "02"
        name   "Plain Joseph"
        nickname "Biz"
        user_id   1
        year  "2017"
        number "4417121029961508"

        factory :visa do
            csv       "323"
            month       "04"
            name       "Ryter Treft"
            nickname    "visa sauce"
            user_id       521
            year       "2018"
            number       "4833160028519277"
        end

        factory :mastercard do
            csv       "641"
            month       "11"
            name       "Rick Makrause"
            nickname    "mastercard sauce"
            user_id       247
            year       "2017"
            number       "5581588784751042"
        end

        factory :amex do
            csv       "8042"
            month       "02"
            name       "Mak Odard"
            nickname    "amex sauce"
            user_id       612
            year       "2016"
            number       "371538495534000"
        end
    end

    factory :sale do
        giver_id    1
        resp_code   1
        #response    AuthResponse.new
        #transaction AuthTransaction.new
        card_id    { FactoryGirl.create(:visa).id }
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

    factory :merchant do
        sequence(:name)    { |n| "ichizos#{n}" }
        city        "New York"
        address     "123 happy st"
        zip         "11211"
        state       "NY"
        sequence(:token)   { |n| "token#{n}" }
        zinger      "its amazing"
        description "get all the japanese culinary delights that are so hard to find in America"
    end

    factory :admin_user do
        sequence(:remember_token)    { |n|  "Token#{n}" }
        sequence(:email)            { |n|  "tester#{n}@gmail.com" }
    end

    factory :brand do
        sequence(:name)    { |n| "Starwoodz#{n}" }
        website     "www.starwood.com"
        description "AMAZING!"
        photo       "res.cloudinary.com/drinkboard/images/kasdhfiaoewhfas.png"
        next_view   "m"
    end

    factory :debt do
        owner { FactoryGirl.create(:provider).biz_user}

    end

    factory :oauth do
        gift_id     100
        token       "9q3562341341"
        secret      "92384619834"
        network     "twitter"
        network_id  "9865465748"
        handle      "razorback"
        photo       "cdn.akai.twitter/791823401974.png"
    end

    factory :oauth_fb, :class => "Oauth" do
        user_id     100
        token       "9q3562341341"
        network     "facebook"
        network_id  "9865465748"
        photo       "cdn.akai.twitter/791823401974.png"
    end

    factory :campaign do
        type_of          "SMS"
        name             "Special Promotion"
        live_date        Time.now.to_date
        close_date       (Time.now + 1.month).to_date
        expire_date      (Time.now + 1.month).to_date
        purchaser_id     1
        purchaser_type   "ItsOnMe"
        giver_name       "Vodka Special Campaign"
        budget           100
        status           "Live"
    end

    factory :campaign_item do
        campaign_id     1
        provider_id     1
        budget          100
        reserve         100
        expires_at      Time.now.to_date
        expires_in     (Time.now + 1.month).to_date
        sms_shortcode   "11111"
        contract        true
    end

end