require 'spec_helper'

describe SubscriptionJob do

    it "should subscribe new user socials" do

    	@user = FactoryGirl.create :user, {first_name: "bob", last_name:"barker"}
        @user_social = UserSocial.where(user_id:@user.id).where(type_of:"email").first
        MailchimpList.any_instance.stub(:subscribe).and_return({"email" => @user.email})
    	run_delayed_jobs
    	@user_social.reload
    	@user_social.subscribed.should == true
    end
end