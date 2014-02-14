require 'spec_helper'
require "mandrill"

describe MailerJob do

    before do
        @gift = FactoryGirl.create :gift, receiver_email: "email.me@gmail.com"
        @gift_item = FactoryGirl.create :gift_item, { gift_id: @gift.id}
        @user = FactoryGirl.create :user, {first_name: "bob", last_name:"barker"}
        ResqueSpec.reset!
    end

    describe :perform do
        it "should call notify receiver" do
            MailerJob.should_receive(:notify_receiver)

            data = {"text"     => 'notify_receiver',
                    "gift_id"  =>  @gift.id}
            MailerJob.perform(data)
        end

        it "should call invoice giver" do
            MailerJob.should_receive(:invoice_giver)

            data = {"text"     => 'invoice_giver',
                    "gift_id"  =>  @gift.id}
            MailerJob.perform(data)
        end
    end

    describe :notify_receiver do
        it "should call mandrill with send_template" do

            MailerJob.stub(:message_hash).and_return("stubbed_message_hash")
            MailerJob.stub(:generate_template_content).and_return("stubbed_template_content")
            Mandrill::API.should_receive(:send_template).with('iom-gift-notify-receiver', "stubbed_template_content", "stubbed_message_hash")
            data = {"text"     => 'notify_receiver',
                    "gift_id"  =>  @gift.id}

            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.notify_receiver(data)
        end
    end

    describe :invoice_giver do
        it "should call mandrill with send_template" do
            MailerJob.stub(:message_hash).and_return("stubbed_message_hash")
            MailerJob.stub(:generate_template_content).and_return("stubbed_template_content")
            Mandrill::API.should_receive(:send_template).with('iom-gift-receipt', "stubbed_template_content", "stubbed_message_hash")

            data = {"text"     => 'invoice_giver',
                    "gift_id"  =>  @gift.id}

            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.invoice_giver(data)
        end
    end

    describe :reminder_gift_receiver do
        it "should call mandrill with send_template" do
            MailerJob.stub(:message_hash).and_return("stubbed_message_hash")
            MailerJob.stub(:generate_template_content).and_return("stubbed_template_content")
            Mandrill::API.should_receive(:send_template).with("iom-gift-unopened-receiver", [{"name"=>"user_name", "content"=>"Jimmy Basic"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], "stubbed_message_hash")

            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift, receiver_id: user.id)

            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_gift_receiver(user)
        end
    end

    describe :reminder_gift_giver do
        it "should call mandrill with send_template" do
            MailerJob.stub(:message_hash).and_return("stubbed_message_hash")
            MailerJob.stub(:generate_template_content).and_return("stubbed_template_content")
            Mandrill::API.should_receive(:send_template).with("iom-gift-unopened-giver", [{"name"=>"user_name", "content"=>"Jimmy Basic"}, {"name"=>"receiver_name", "content"=>"Someone New"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], "stubbed_message_hash")

            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift, giver: user)


            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_gift_giver(user, gift.receiver_name)
        end
    end
end