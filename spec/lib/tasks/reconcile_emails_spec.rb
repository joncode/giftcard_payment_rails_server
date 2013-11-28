require 'spec_helper'
require 'rake'

describe "reconcile_emails rake tasks" do

	before do
		load File.expand_path(Rails.root.join('lib', 'tasks', 'reconcile_emails.rake'))
		Rake::Task.define_task(:environment)
	end

    describe "mc_subscriptions" do
        it "should send unsubscribed new user socials to queue" do
	        user_social = FactoryGirl.create :user_social
	        user_social.subscribed.should == false
	        Resque.should_receive(:enqueue)
	        Rake::Task["email:mc_subscriptions"].invoke
        end
    end

    describe "gift_emails_count" do
	    before do
	        gift = FactoryGirl.create :gift, {receiver_email: "jim@email.com"}
	        gift_item = FactoryGirl.create :gift_item, { gift_id: gift.id }
	        user = FactoryGirl.create :user, {first_name: "bob", last_name:"barker"}
	    end

        xit "should description" do
        	require 'mandrill'
            Mandrill::API.stub_chain(:new, :messages, :search){ [{"email" => "#{INFO_EMAIL}", "subject" => "Bob sent you a gift on #{SERVICE_NAME}"},
            													 {"email" => "bob@email.com", "subject" => "Bob sent you a gift on #{SERVICE_NAME}"}] }
            Resque.should_receive(:enqueue)
	        Rake::Task["email:gift_emails_count"].invoke
        end
    end


end