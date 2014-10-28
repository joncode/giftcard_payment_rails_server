require 'spec_helper'


describe RegisterPushJob do

    describe :perform do

        before(:each) do
            ResqueSpec.reset!
            RegisterPushJob.stub(:ua_register)
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
        #stub_request(:put, "https://q_NVI6G1RRaOU49kKTOZMQ:yQEhRtd1QcCgu5nXWj-2zA@go.urbanairship.com/api/apids/FAKE_PN_TOKENFAKE_PN_TOKEN").with(:body => "{\"alias\":\"user-#{@user.obscured_id}\",\"provider\":\"android\"}", :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
        #RegisterPushJob.stub(:ua_register)
        @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token, platform: "android")
        correct_alias = "user-#{ @user.id + NUMBER_ID }"


        Urbanairship.should_receive(:register_device).with("FAKE_PN_TOKENFAKE_PN_TOKEN", :alias => correct_alias, :provider => :android)
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:call_mandrill).and_return(true)
        run_delayed_jobs
    end

end