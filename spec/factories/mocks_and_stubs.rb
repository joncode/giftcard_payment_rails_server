module MocksAndStubs

    #include MocksAndStubs

	def relay_stubs confirm_email: nil, register_push: nil, subscribe_email: nil, mailer_job: nil
        resque_stubs
        User.any_instance.stub(:persist_social_data).and_return(true)
	end

	def stub_incomplete_push user_alias, receiver_name
		stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").with(:body => "{\"aliases\":[\"#{user_alias}\"],\"aps\":{\"alert\":\"Thank You! #{receiver_name} got the app and your gift!\",\"badge\":0,\"sound\":\"pn.wav\"},\"alert_type\":2,\"android\":{\"alert\":\"Thank You! #{receiver_name} got the app and your gift!\"}}").to_return(:status => 200, :body => "", :headers => {})
	end

    def resque_stubs confirm_email: nil, register_push: nil, subscribe_email: nil, mailer_job: nil
        ResqueSpec.reset!
        User.any_instance.stub(:init_confirm_email).and_return(true) unless confirm_email
        RegisterPushJob.stub(:perform).and_return(true)              unless register_push
        SubscriptionJob.stub(:perform).and_return(true)              unless subscribe_email
        MailerJob.stub(:perform).and_return(true)                    unless mailer_job
    end

    def tokenize_credential_url
        'https://apitest.authorize.net/xml/v1/request.api'
    end

    def tokenize_credential_body
        '<?xml version="1.0" encoding="utf-8"?><mobileDeviceLoginRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><merchantAuthentication><name>Dbtestapp1</name><password>10Brown15</password><mobileDeviceId>' + AUTHORIZE_MOBILE_DEVICE + '</mobileDeviceId></merchantAuthentication></mobileDeviceLoginRequest>'
    end

    def test_confirm_email
        resque_stubs mailer_job: true, confirm_email: true

        MailerJob.should_receive(:request_mandrill_with_template).once
        Mandrill::API.stub(:new) { Mandrill::API }
        #Mandrill::API.should_receive(:send_template).with("iom-confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"#{NO_REPLY_EMAIL}", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"#{INFO_EMAIL}", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})
        Mandrill::API.any_instance.stub(:messages).with("iom-confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"#{NO_REPLY_EMAIL}", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"#{INFO_EMAIL}", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})
        yield
        run_delayed_jobs
    end

    def test_subscribed_email
        resque_stubs subscribe_email: true
        MailchimpList.any_instance.should_receive(:subscribe).and_return({"email" => "neil@gmail.com" })
        yield
        run_delayed_jobs
        user = UserSocial.find_by(identifier: "neil@gmail.com")
        user.subscribed.should be_true
    end

    def test_urban_airship_endpoint(platform='ios', pn_token=nil)
        resque_stubs register_push: true
        pn_token = pn_token || "FAKE_PN_TOKENFAKE_PN_TOKEN"
        ua_alias = "fake_ua"
        PnToken.any_instance.stub(:ua_alias).and_return("fake_ua")
        Urbanairship.should_receive(:register_device).with(pn_token, { :alias => ua_alias, :provider => platform.to_sym})
        yield(pn_token)
        run_delayed_jobs # ResqueSpec.perform_all(:push)
    end

    def test_urban_airship_gift_opened gift
        resque_stubs
        ua_alias = gift.giver.ua_alias
        badge = Gift.get_notifications(gift.giver)
        good_push_hsh = {:aliases =>[ua_alias],:aps =>{:alert => "#{gift.receiver_name} opened your gift at #{gift.provider_name}!",:badge=>badge,:sound=>"pn.wav"},:alert_type=>2,:android =>{:alert => "#{gift.receiver_name} opened your gift at #{gift.provider_name}!"}}
        Urbanairship.should_receive(:push).with(good_push_hsh)
        yield
        run_delayed_jobs # ResqueSpec.perform_all(:push)
    end

    def test_pn_token_persisted token=nil
        # yield block must return the platform
        resque_stubs register_push: true
        token ||= "91283419asdfasdfasdfasdfasdfa83439487123"
        RegisterPushJob.stub(:ua_register)
        platform = yield(token)
        run_delayed_jobs
        pn_token = PnToken.where(pn_token: token).first
        pn_token.pn_token.should == token
        pn_token.class.should    == PnToken
        pn_token.user_id.should  == @user.id
        pn_token.platform.should == platform
    end
end