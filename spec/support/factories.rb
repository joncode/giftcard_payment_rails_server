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
        name        "ichizos"
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
              phone + (2..8).to_a.sample.to_s
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

    factory :gift do |gift|
        giver_id        13
        giver_name      "henry"
        receiver_name   "jon"
        provider { FactoryGirl.create(:provider)}
        total           "100"
        service         "4"
        credit_card     "4567890"
    end

end