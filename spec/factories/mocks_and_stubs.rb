module MockAndStubs

	def relay_stubs
        ResqueSpec.reset!
        User.any_instance.stub(:init_confirm_email).and_return(true)
        User.any_instance.stub(:persist_social_data).and_return(true)
        RegisterPushJob.stub(:perform).and_return(true)
        SubscriptionJob.stub(:perform).and_return(true)
        MailerJob.stub(:perform).and_return(true)
	end


end