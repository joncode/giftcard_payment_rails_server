FactoryGirl.define do

    factory :user do
        first_name "jon"
        password   "specspec"
        password_confirmation "specspec"
        email      "joncode@gmail.com"
        remember_token "token"
        facebook_id "987654332"
        twitter     "283746193"
        phone       "6467578686"
    end

    factory :giver do
        first_name "jon2"
        password   "specspec2"
        password_confirmation "specspec2"
        email      "jonran@gmail.com"
        remember_token "token"
        facebook_id "98asd54332"
        twitter     "283sdf6193"
        phone       "6443278686"
    end

    factory :provider do
        name        "ichizos"
        city        "New York"
        address     "123 happy st"
        zip         "11211"
        state       "NY"
        zinger      "its amazing"
        description "get all the japanese culinary delights that are so hard to find in America"
        sequence(:token) { |n| n.to_s + "token" }
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
        gift.giver_id        13
        gift.giver_name      "henry"
        gift.receiver_name   "jon"
        gift.provider { FactoryGirl.create(:provider)}
        gift.total           "100"
        gift.service         "4"
        gift.credit_card     "4567890"
    end

end