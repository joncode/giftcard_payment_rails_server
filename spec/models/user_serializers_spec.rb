require 'spec_helper'

describe UserSerializers do

    it "should profile serialize multiple user socials" do
        user = FactoryGirl.create(:user)
        user.email = "new_email@gmail.com"
        user.phone = "7568459384"
        user.facebook_id = "1111111111"
        user.twitter = "342342342"
        user.save
        json_str = user.profile_serialize

        keys = ["first_name", "last_name", "birthday", "zip", "email", "sex", "phone", "facebook_id", "twitter", "user_id", "photo"]
        compare_keys json_str, keys

        emails = json_str["email"]
        emails.count.should == 2
        phone = json_str["phone"]
        phone.count.should == 2
        facebook_id = json_str["facebook_id"]
        facebook_id.count.should == 2
        twitter = json_str["twitter"]
        twitter.count.should == 2
    end

    it "should profile serialize and put single items in an array" do
        user = FactoryGirl.create(:user)
        user.save
        json_str = user.profile_serialize

        keys = ["first_name", "last_name", "birthday", "zip", "email", "sex", "phone", "facebook_id", "twitter", "user_id", "photo"]
        compare_keys json_str, keys
        emails = json_str["email"]
        emails.class.should == Array
        phone = json_str["phone"]
        phone.class.should == Array
        facebook_id = json_str["facebook_id"]
        facebook_id.class.should == Array
        twitter = json_str["twitter"]
        twitter.class.should == Array
    end

end