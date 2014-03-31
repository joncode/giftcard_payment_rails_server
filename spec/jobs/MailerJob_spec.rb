require 'spec_helper'
require "mandrill"

describe MailerJob do

    before(:each) do
        # Provider.delete_all
        # User.delete_all
        # Gift.delete_all
        # GiftItem.delete_all
        @provider = FactoryGirl.create :provider, name: "Merchies"
        @giver = FactoryGirl.create :user, first_name: "Givie", last_name: "Giverson", email: "givie@email.com"
        @receiver = FactoryGirl.create :user, first_name: "Receivy", last_name: "Receiverson", email: "receivy@email.com"
        @gift = FactoryGirl.create :gift, receiver_email: @receiver.email,
                                          receiver_name: @receiver.name,
                                          receiver_id: @receiver.id,
                                          provider: @provider,
                                          giver: @giver,
                                          giver_name: @giver.name
        @gift_item = FactoryGirl.create :gift_item, { gift_id: @gift.id}
    end
    before(:each) do
        ResqueSpec.reset!
    end
    # after(:all) do
    #     Provider.delete_all
    #     User.delete_all
    #     Gift.delete_all
    #     GiftItem.delete_all
    # end

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

    describe :reset_password do
        it "should call mandrill with send_template" do
            template_name = "iom-reset-password"
            template_content = [{ "name" => "recipient_name", "content" => "Receivy Receiverson"},
                                { "name" => "service_name", "content" => "ItsOnMe" }]
            message_hash = { "subject" => "Reset Your Password",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>"http://0.0.0.0:3001/account/resetpassword/"}]}] }
            data = { "text" => 'reset_password', "user_id" => @receiver.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reset_password(data)
        end
    end

    describe :confirm_email do
        it "should call mandrill with send_template" do
            template_name = "iom-confirm-email"
            template_content = [{ "name" => "recipient_name", "content" => "Receivy Receiverson"},
                                { "name" => "service_name", "content" => "ItsOnMe" }]
            message_hash = { "subject" => "Confirm Your Email",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}] }
            data = { "text" => 'confirm_email', "user_id" => @receiver.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.confirm_email(data)
        end
    end

    describe :welcome do
        it "should call mandrill with send_template" do
            template_name = "iom-user-welcome"
            template_content = [{"name" => "user_name", "content" => "Receivy Receiverson"}]
            message_hash = { "subject" => "Welcome to ItsOnMe!",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}] }
            data = { "text" => 'welcome', "user_id" => @receiver.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.welcome(data)
        end
    end

    describe :notify_receiver do
        it "should call mandrill with send_template" do
            template_name = "iom-gift-notify-receiver"
            template_content = [{ "name" => "receiver_name", "content" => "Receivy Receiverson" },
                                { "name" => "merchant_name", "content" => "Merchies" },
                                { "name" => "gift_details", "content" => "<ul><li>1 Original Margarita </li></ul>" },
                                { "name" => "gift_total", "content" => "100" },
                                { "name" => "service_name", "content" => "ItsOnMe" },
                                { "name" => "giver_name", "content" => "Givie Giverson" }]
            message_hash = { "subject" => "Givie Giverson sent you a gift on ItsOnMe",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>"http://0.0.0.0:3001/signup/acceptgift/#{NUMBER_ID + @gift.id}"}]}] }
            data = { "text" => 'notify_receiver', "gift_id" => @gift.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.notify_receiver(data)
        end
    end

    describe :invoice_giver do
        it "should call mandrill with send_template" do
            template_name = "iom-gift-receipt"
            template_content = [{ "name" => "receiver_name", "content" => "Receivy Receiverson" },
                                { "name" => "merchant_name", "content" => "Merchies" },
                                { "name" => "gift_details", "content" => "<ul><li>1 Original Margarita </li></ul>" },
                                { "name" => "gift_total", "content" => "100" },
                                { "name" => "service_name", "content" => "ItsOnMe" },
                                { "name" => "user_name", "content" => "Givie Giverson"},
                                { "name" => "processing_fee", "content" => "4" },
                                { "name" => "grand_total", "content" => "104" }]
            message_hash = { "subject" => "Your gift purchase is complete",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"givie@email.com", "name"=>"Givie Giverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"givie@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}] }
            data = { "text" => 'invoice_giver', "gift_id" => @gift.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.invoice_giver(data)
        end
    end

    describe :reminder_gift_giver do
        it "should call mandrill with send_template" do
            template_name = "iom-gift-unopened-giver"
            template_content = [{ "name" => "user_name", "content" => "Givie Giverson" },
                                { "name" => "receiver_name", "content" => "Receivy Receiverson" },
                                { "name" => "service_name", "content" => "ItsOnMe" }]
            message_hash = { "subject" => "Receivy Receiverson hasn't opened your gift",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"givie@email.com", "name"=>"Givie Giverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"givie@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}]}
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_gift_giver(@giver, @gift.receiver_name)
        end
    end

    describe :reminder_hasnt_gifted do
        it "should call mandrill with send_template" do
            template_name = "iom-gift-hasnt-gifted"
            template_content = [{ "name" => "user_name", "content" => "Givie Giverson" },
                                { "name" => "service_name", "content" => "ItsOnMe" }]
            message_hash = { "subject" => "ItsOnMe Is Ready to Fulfill Your Mobile Gifting Needs!",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"givie@email.com", "name"=>"Givie Giverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"givie@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}] }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_hasnt_gifted(@giver)
        end
    end

    describe :reminder_gift_receiver do
        it "should call mandrill with send_template" do
            template_name = "iom-gift-unopened-receiver"
            template_content = [{ "name" => "user_name", "content" => "Receivy Receiverson" },
                                { "name" => "service_name", "content" => "ItsOnMe" }]
            message_hash = { "subject" => "You have gifts waiting for you!", 
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}, {"email"=>"info@itson.me", "name"=>""}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}]}
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash)
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_gift_receiver(@receiver)
        end
    end
end