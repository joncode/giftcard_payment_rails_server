require 'spec_helper'

describe SubscriptionJob do

    it "should find deactivated user socials and remove from mailchimp" do
        user = FactoryGirl.create(:simple_user, email: "toBe_deactivated@deactive.com")
        MailchimpList.any_instance.stub(:subscribe).and_return({"email" => user.email})

        user_social = user.user_socials.where(type_of: "email").first
        #user_social.subscribed.should be_false
        run_delayed_jobs

        user_social.reload
        #user_social.subscribed.should be_true
        SubscriptionJob.should_receive(:perform).with(user_social.id)
        SubscriptionJob.should_receive(:remove_from_mailchimp)
        user.permanently_deactivate
        run_delayed_jobs

        user_social.reload
        user_social.active.should be_false
    end
end