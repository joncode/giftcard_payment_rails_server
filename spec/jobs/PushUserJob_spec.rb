require 'spec_helper'
include MockAndStubs

describe PushUserJob do

    before(:each) do
        User.delete_all
        PnToken.delete_all
        Provider.delete_all
        RegisterPushJob.stub(:ua_register)
        @user     = FactoryGirl.create(:user)
        @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
        @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token)

    end

    it "should send alias & correct badge to Urban Airship" do
        resque_stubs
        user_alias = @pnt.ua_alias
        prov_name  = "Push Testers"
        alert = "This is the message from admin tools"
        good_push_hsh   = {
            :aliases => [@pnt.ua_alias],
            :aps => {
                :alert => alert,
                :badge => 0,
                :sound => 'pn.wav'
            },
            :alert_type => 3,
            :android => {
                :alert => alert
            }
        }
        run_delayed_jobs
        Urbanairship.should_receive(:push).with(good_push_hsh).and_return({"push_id"=>"39f42812-0665-11e4-bc49-90e2ba272c68"})
        PushUserJob.perform({
                "alert" => "This is the message from admin tools",
                "user_id" => @user.id })
        d                     = Ditto.last
        d.notable_id.should   == @user.id
        d.notable_type.should == 'User'
        d.status.should       == 200
        d.cat.should          == 110
    end

end
