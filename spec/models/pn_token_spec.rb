require 'spec_helper'

describe PnToken do

    # it "should register PN Token with Resque" do
    #     RegisterPushJob.stub(:ua_register)
    #     user     = FactoryGirl.create(:user)
    #     ResqueSpec.reset!
    #     pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
    #     pnt      = PnToken.new(user_id: user.id, pn_token: pn_token)
    #     #pnt.stub({:id => 1})
    #     Resque.should_receive(:enqueue).with(RegisterPushJob, anything)
    #     pnt.save
    # end

    it "should default the platform to 'ios'" do
        RegisterPushJob.stub(:ua_register)
        user     = FactoryGirl.create(:user)
        pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
        pnt      = PnToken.new(user_id: user.id, pn_token: pn_token)
        pnt.save
        pnt.reload
        pnt.platform.should == 'ios'
    end

    # it "should register pn token alternative version (remix)" do
    #     RegisterPushJob.stub(:ua_register)
    #     user = FactoryGirl.create(:user)
    #     ResqueSpec.reset!
    #     pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
    #     pnt = PnToken.new(user_id: user.id, pn_token: pn_token)
    #     running { pnt.save }.should change {
    #         ResqueSpec.queues["push"].size
    #     }.by 1
    #     ResqueSpec.queues["push"].last[:args].first.should == pnt.id
    # end

end# == Schema Information
#
# Table name: pn_tokens
#
#  id       :integer         not null, primary key
#  user_id  :integer
#  pn_token :string(255)
#

# == Schema Information
#
# Table name: pn_tokens
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  pn_token   :string(255)
#  platform   :string(255)     default("ios")
#  created_at :datetime
#  updated_at :datetime
#

