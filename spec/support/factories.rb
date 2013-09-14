FactoryGirl.define do

    factory :user do

        first_name "jon"
        password   "specspec"
        password_confirmation "specspec"
        email      "joncode@gmail.com"

    end

    factory :user_social do
        user_id     1
        type        "email"
        identifier  "example@gmail.com"
    end


end