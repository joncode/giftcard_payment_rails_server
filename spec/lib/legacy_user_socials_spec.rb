require 'spec_helper'
require 'legacy_user_socials'
include LegacyUserSocials

describe LegacyUserSocials do

    describe :create_user_socials do

        it "should make user_social out of user info" do
            user = FactoryGirl.create(:user, email: "tester@test.com", phone: "456-768-8574", facebook_id: "2983641924", twitter: "836528342")
            UserSocial.delete_all
            create_user_socials
            uss = UserSocial.where(user_id: user.id)
            uss.count.should == 4
            email = uss.where(identifier: "tester@test.com")
            email.count.should == 1
            phone = uss.where(identifier: "4567688574")
            phone.count.should == 1
            fb = uss.where(identifier: "2983641924")
            fb.count.should == 1
            twitter = uss.where(identifier: "836528342")
            twitter.count.should == 1
        end

        it "should not make user_socials out of user info when user socials already exist" do
            user = FactoryGirl.create(:user, email: "tester@test.com", phone: "456-768-8574", facebook_id: "2983641924", twitter: "836528342")
            UserSocial.delete_all
            create_user_socials
            UserSocial.should_not_receive(:create)
            uss = UserSocial.where(user_id: user.id)
            uss.count.should == 4
            email = uss.where(identifier: "tester@test.com")
            email.count.should == 1
            phone = uss.where(identifier: "4567688574")
            phone.count.should == 1
            fb = uss.where(identifier: "2983641924")
            fb.count.should == 1
            twitter = uss.where(identifier: "836528342")
            twitter.count.should == 1
        end
    end


end