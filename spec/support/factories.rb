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
        credit_card     "4567890"
        shoppingCart    "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]"
    end

    factory :sale do
        giver_id    1
        gift_id     1
        resp_code   1
        response    AuthResponse.new("{\"response_code\":\"1\",\"response_subcode\":\"1\",\"response_reason_code\":\"1\",\"response_reason_text\":\"This transaction has been approved.\",\"authorization_code\":\"181515\",\"avs_response\":\"P\",\"transaction_id\":\"5573834199\",\"invoice_number\":\"\",\"description\":\"\",\"amount\":\"16.8\",\"method\":\"CC\",\"transaction_type\":\"auth_capture\",\"customer_id\":\"\",\"first_name\":\"David\",\"last_name\":\"Leibner\",\"company\":\"\",\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip_code\":\"\",\"country\":\"\",\"phone\":\"\",\"fax\":\"\",\"email_address\":\"\",\"ship_to_first_name\":\"\",\"ship_to_last_name\":\"\",\"ship_to_company\":\"\",\"ship_to_address\":\"\",\"ship_to_city\":\"\",\"ship_to_state\":\"\",\"ship_to_zip_code\":\"\",\"ship_to_country\":\"\",\"tax\":\"0.0\",\"duty\":\"0.0\",\"freight\":\"0.0\",\"tax_exempt\":\"\",\"purchase_order_number\":\"\",\"md5_hash\":\"1E902F33186C2766D04D491478CBD1F5\",\"card_code_response\":\"\",\"cardholder_authentication_verification_response\":\"\",\"account_number\":\"XXXX4628\",\"card_type\":\"Visa\"}")
        transaction AuthTransaction.new("{\"first_name\":\"David\",\"last_name\":\"Leibner\",\"method\":\"CC\",\"card_num\":\"XXXX4628\",\"exp_date\":\"0617\",\"amount\":\"16.8\"}")
    end

end