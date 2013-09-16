FactoryGirl.define do

    factory :user do
        first_name "jon"
        password   "specspec"
        password_confirmation "specspec"
        email      "joncode@gmail.com"
        remember_token "token"
    end

    factory :provider do
        name        "ichizos"
        city        "New York"
        address        "123 happy st"
        zip         "11211"
        state       "NY"
        token       "token"
    end

    factory :user_social do
        user_id     1
        type        "email"
        identifier  "example@gmail.com"
    end

    factory :gift do |gift|
        gift.giver { FactoryGirl.create(:user)}
        gift.giver_name      "henry"
        gift.receiver_name   "jon"
        gift.provider { FactoryGirl.create(:provider)}
        gift.total           "100"
        gift.service         "4"
        gift.credit_card     "4567890"
    end

end