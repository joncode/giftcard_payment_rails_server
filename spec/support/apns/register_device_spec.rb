require 'spec_helper'


shared_examples_for "register pn_token" do | verb, route, params|

    it "should hit urban airship endpoint with correct token and alias" do
        PnToken.any_instance.stub(:ua_alias).and_return("fake_ua")
        User.any_instance.stub(:pn_token).and_return("FAKE_PN_TOKENFAKE_PN_TOKEN")
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:call_mandrill).and_return(true)
        pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
        ua_alias = "fake_ua"

        Urbanairship.should_receive(:register_device).with(pn_token, { :alias => ua_alias})
        puts "-----------#{verb} | #{route} | #{params} ------------"
        send(verb, route, params, format: :json)
        run_delayed_jobs
    end

end