require 'spec_helper'

include MockAndStubs

describe Relay do

    it "should route push for incomplete" do
        relay_stubs
        user      = FactoryGirl.create(:user)
        pn_token  = "FAKE_PN_TOKENFAKE_PN_TOKEN"
        pnt       = PnToken.create(user_id: user.id, pn_token: pn_token)
        prov_name = "Pusher's"
        receiver  = FactoryGirl.build(:receiver)
        gift      = FactoryGirl.create(:gift, giver: user, receiver_name: receiver.name, receiver_email: receiver.email, provider_name: prov_name)

        gift.set_statuses
        gift.status.should == 'incomplete'
        user_alias    = pnt.ua_alias
        good_push_hsh = {:aliases =>["#{user_alias}"],:aps =>{:alert => "Thank You! #{gift.receiver_name} got the app and your gift!",:badge=>0,:sound=>"pn.wav"},:alert_type=>2}

        Urbanairship.should_receive(:push).with(good_push_hsh)
        Relay.send_push_incomplete gift
        run_delayed_jobs
    end

end