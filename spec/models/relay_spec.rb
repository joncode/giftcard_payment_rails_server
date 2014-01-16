require 'spec_helper'

describe Relay do

    it "should route push for incomplete" do
        ResqueSpec.reset!
        User.any_instance.stub(:init_confirm_email).and_return(true)
        User.any_instance.stub(:persist_social_data).and_return(true)
        RegisterPushJob.stub(:perform).and_return(true)
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:perform).and_return(true)
        @user     = FactoryGirl.create(:user)
        @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
        @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token)
        prov_name = "Pusher's"
        receiver  = FactoryGirl.build(:receiver)
        @gift     = FactoryGirl.create(:gift, giver: @user, receiver_name: receiver.name, receiver_email: receiver.email, provider_name: prov_name)
        @gift.status.should == 'incomplete'
        user_alias = @pnt.ua_alias
        good_push_hsh = {:aliases =>["#{user_alias}"],:aps =>{:alert => "Thank You! #{@gift.receiver_name} got the app and your gift!",:badge=>0,:sound=>"pn.wav"},:alert_type=>2}

        Urbanairship.should_receive(:push).with(good_push_hsh)
        Relay.send_push_incomplete @gift
        run_delayed_jobs
    end

end