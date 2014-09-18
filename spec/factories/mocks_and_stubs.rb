module MockAndStubs

	def relay_stubs
        ResqueSpec.reset!
        User.any_instance.stub(:init_confirm_email).and_return(true)
        User.any_instance.stub(:persist_social_data).and_return(true)
        RegisterPushJob.stub(:perform).and_return(true)
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:perform).and_return(true)
	end

	def stub_incomplete_push user_alias, receiver_name
		stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").with(:body => "{\"aliases\":[\"#{user_alias}\"],\"aps\":{\"alert\":\"Thank You! #{receiver_name} got the app and your gift!\",\"badge\":0,\"sound\":\"pn.wav\"},\"alert_type\":2,\"android\":{\"alert\":\"Thank You! #{receiver_name} got the app and your gift!\"}}").to_return(:status => 200, :body => "", :headers => {})
	end

    def resque_stubs
        ResqueSpec.reset!
        User.any_instance.stub(:init_confirm_email).and_return(true)
        RegisterPushJob.stub(:perform).and_return(true)
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:perform).and_return(true)
    end

    def tokenize_credential_url
        'https://apitest.authorize.net/xml/v1/request.api'
    end

    def tokenize_credential_body
        '<?xml version="1.0" encoding="utf-8"?><mobileDeviceLoginRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><merchantAuthentication><name>Dbtestapp1</name><password>10Brown15</password><mobileDeviceId>' + AUTHORIZE_MOBILE_DEVICE + '</mobileDeviceId></merchantAuthentication></mobileDeviceLoginRequest>'
    end


end