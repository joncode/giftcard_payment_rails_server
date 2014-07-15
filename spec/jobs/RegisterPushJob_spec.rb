require 'spec_helper'


describe RegisterPushJob do

    describe :perform do

        before(:each) do
             ResqueSpec.reset!
            @user     = FactoryGirl.create(:user)
            @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token)
        end

        it "should send PnToken & correct alias to Urban Airship" do
            adj_user_id   = @user.id + NUMBER_ID
            correct_alias = "user-#{adj_user_id}"
            Urbanairship.should_receive(:register_device).with(@pn_token, :alias => correct_alias, :provider => :ios)
            SubscriptionJob.stub(:perform).and_return(true)
            MailerJob.stub(:call_mandrill).and_return(true)
            run_delayed_jobs
        end

        it "should create a ditto for register device" do
            adj_user_id   = @user.id + NUMBER_ID
            correct_alias = "user-#{adj_user_id}"
            Urbanairship.should_receive(:register_device).with(@pn_token, :alias => correct_alias, :provider => :ios).and_return( {"error_code"=>40001, "details"=>{"device_token"=>["device_token contains an invalid device token: A7D14290-FD57-41F0-B1A4-DB36F6E9B79B"]}, "error"=>"Data validation error"})
            SubscriptionJob.stub(:perform).and_return(true)
            MailerJob.stub(:call_mandrill).and_return(true)
            run_delayed_jobs
            d = Ditto.last
            d.notable_type.should == "User"
            d.notable_id.should   == @user.id
        end

    end

    it "should send register android and ios to correct respective route" do
        ResqueSpec.reset!
        @user     = FactoryGirl.create(:user)
        @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
        @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token, platform: "android")
        correct_alias = "user-#{ @user.id + NUMBER_ID }"


        Urbanairship.should_receive(:register_device).with(@pn_token, :alias => correct_alias, :provider => :android)
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:call_mandrill).and_return(true)
        run_delayed_jobs
    end

end