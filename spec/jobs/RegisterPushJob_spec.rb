require 'spec_helper'


describe RegisterPushJob do

    describe :perform do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token)
        end

        it "should send PnToken & correct alias to Urban Airship" do
            adj_user_id = @user.id + NUMBER_ID
            correct_alias = "user-#{adj_user_id}"
            Urbanairship.should_receive(:register_device).with(@pn_token, :alias => correct_alias)
            SubscriptionJob.stub(:perform).and_return(true)
            MailerJob.stub(:call_mandrill).and_return(true)
            run_delayed_jobs
        end

    end

end