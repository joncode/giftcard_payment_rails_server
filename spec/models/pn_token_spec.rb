require 'spec_helper'

describe PnToken do

    it "should register PN Token with Resque" do

        user     = FactoryGirl.create(:user)
        pn_token = "FAKE_PN_TOKEN"
        pnt      = PnToken.new(user_id: user.id, pn_token: pn_token)
        #pnt.stub({:id => 1})
        Resque.should_receive(:enqueue).with(RegisterPushJob, anything)
        pnt.save
    end

    it "should register pn token alternative version (remix)" do
        user = FactoryGirl.create(:user)
        pn_token = "FAKE_PN_TOKEN"
        pnt = PnToken.new(user_id: user.id, pn_token: pn_token)
        running { pnt.save }.should change {
            ResqueSpec.queues["push"].size
        }.by 1
        ResqueSpec.queues["push"].last[:args].first.should == pnt.id
    end

end