require 'spec_helper'
require 'mandrill'

describe SubscriptionJob do

    before do
        User.delete_all
        UserSocial.delete_all
        ResqueSpec.reset!
    end

    it "should find suspended user socials and remove from mailchimp" do
        User.any_instance.stub(:init_confirm_email)
        user = FactoryGirl.create(:user, email: "toBe_deactivated@deactive.com")
        MailchimpList.any_instance.stub(:subscribe).and_return({"email" => user.email, "euid"=>"931908a11a", "leid"=>"117276957"})
        run_delayed_jobs

        user_social = user.user_socials.where(type_of: "email").first
        SubscriptionJob.should_receive(:remove_from_mailchimp)
        user.suspend
        run_delayed_jobs

        user_social.reload
        user_social.active.should be_false
        d                     = Ditto.where(cat: 400).last
        d.notable_id.should   == user_social.id
        d.notable_type.should == 'UserSocial'
        d.status.should       == 200
        d.cat.should          == 400
    end

    it "should find perm_deactive user socials and remove from mailchimp" do
        User.any_instance.stub(:init_confirm_email)
        user = FactoryGirl.create(:user, email: "toBe_deactivated@deactive.com")
        MailchimpList.any_instance.stub(:subscribe).and_return({"email" => user.email, "euid"=>"931908a11a", "leid"=>"117276957"})
        run_delayed_jobs

        user_social = user.user_socials.where(type_of: "email").first
        SubscriptionJob.should_receive(:remove_from_mailchimp)
        user.permanently_deactivate
        run_delayed_jobs

        user_social.reload
        user_social.active.should be_false
        d                     = Ditto.where(cat: 400).last
        d.notable_id.should   == user_social.id
        d.notable_type.should == 'UserSocial'
        d.status.should       == 200
        d.cat.should          == 400
    end

    it "should subscribe new user socials" do
        User.any_instance.stub(:init_confirm_email)
        user = FactoryGirl.create :user, {first_name: "bob", last_name:"barker"}
        user_social = UserSocial.where(user_id: user.id).where(type_of: "email").first

        user_social.subscribed.should == false
        MailchimpList.any_instance.stub(:subscribe).and_return({"email" => user.email, "euid"=>"931908a11a", "leid"=>"117276957"})
        run_delayed_jobs
        user_social.reload
        user_social.subscribed.should == true
        d                     = Ditto.where(cat: 400).last
        d.notable_id.should   == user_social.id
        d.notable_type.should == 'UserSocial'
        d.status.should       == 200
        d.cat.should          == 400
    end

    it "should not fail calling 'active' on a AR::Relation" do
        User.any_instance.stub(:init_confirm_email)
        user = FactoryGirl.create :user, {first_name: "bob", last_name:"barker"}
        user_social = UserSocial.where(user_id: user.id).where(type_of: "email").first

        user_social.subscribed.should == false
        MailchimpList.any_instance.stub(:subscribe).and_return({"email" => user.email, "euid"=>"931908a11a", "leid"=>"117276957"})
        run_delayed_jobs
        user_social.reload
        user_social.subscribed.should == true
        d                     = Ditto.where(cat: 400).last
        d.notable_id.should   == user_social.id
        d.notable_type.should == 'UserSocial'
        d.status.should       == 200
        d.cat.should          == 400
    end
end