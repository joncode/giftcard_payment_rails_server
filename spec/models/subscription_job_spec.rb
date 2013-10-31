require 'spec_helper'

describe SubscriptionJob do

    it "should register PN Token with Resque" do

    	@user = FactoryGirl.create :user, {first_name: "bob", last_name:"barker"}
    	@user_social = FactoryGirl.create :user_social, {user_id: @user.id}
        MailchimpList.any_instance.stub(:subscribe).and_return({"email" => @user.email})
    	SubscriptionJob.perform(@user_social.id)
    	@user_social.reload
    	@user_social.subscribed.should == true
    end

end