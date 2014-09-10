require 'spec_helper'
require "mandrill"
include EmailHelper

describe MailerJob do

    before(:each) do
        ResqueSpec.reset!
        @merchant = FactoryGirl.create :merchant
        @provider = FactoryGirl.create :provider, name: "Merchies", merchant_id: @merchant
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
            body             = text_for_user_reset_password(@receiver)
            template_name    = "user"
            template_content = [{ "name" => "body", "content" => body }]
            message          = {
                "subject"     => "QA - Reset password request",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => @receiver.email, "name" => @receiver.name }],
                "merge_vars"  => [{
                    "rcpt" => @receiver.email,
                    "vars" => template_content
                }]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text" => "reset_password",
                "user_id" => @receiver.id
            }
            MailerJob.reset_password(data)
            d                     = Ditto.last
            d.notable_id.should   == @receiver.id
            d.notable_type.should == 'User'
            d.status.should       == 200
            d.cat.should          == 310

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
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}],
                             "bcc_address" => "info@itson.me",
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}] }
            data = { "text" => 'confirm_email', "user_id" => @receiver.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.confirm_email(data)
            d                     = Ditto.last
            d.notable_id.should   == @receiver.id
            d.notable_type.should == 'User'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :welcome_from_dave do
        it "should call mandrill without template" do
            text = text_for_welcome_from_dave(@receiver)
            message = {
                "subject"     => "Please share your feedback",
                "from_name"   => "David Leibner",
                "from_email"  => "david.leibner@itson.me",
                "text"        => text,
                "to"          => [{
                    "email" => @receiver.email,
                    "name"  => @receiver.name
                }]
            }
            Mandrill::API.should_receive(:send).with(message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = { "text" => 'welcome', "user_id" => @receiver.id }
            MailerJob.welcome_from_dave(data)
            d                     = Ditto.last
            d.notable_id.should   == @receiver.id
            d.notable_type.should == 'User'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :notify_receiver do
        it "should call mandrill with send_template" do
            template_name = "iom-gift-notify-receiver"
            template_content = [{ "name" => "receiver_name", "content" => "Receivy Receiverson" },
                                { "name" => "merchant_name", "content" => "Merchies" },
                                { "name" => "gift_details", "content" => "<ul style='list-style-type:none;'><li>1 Original Margarita </li></ul>" },
                                { "name" => "gift_total", "content" => "100" },
                                { "name" => "service_name", "content" => "ItsOnMe" },
                                { "name" => "giver_name", "content" => "Givie Giverson" }]
            message_hash = { "subject" => "Givie Giverson sent you a gift on ItsOnMe",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>"http://0.0.0.0:3001/signup/acceptgift?id=#{NUMBER_ID + @gift.id}"}]}] }
            data = { "text" => 'notify_receiver', "gift_id" => @gift.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.notify_receiver(data)
            d                     = Ditto.last
            d.notable_id.should   == @gift.id
            d.notable_type.should == 'Gift'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :notify_receiver_boomerang do
        it "should call mandrill with send_template" do
            boomgift = FactoryGirl.create :gift, payable: @gift, receiver_name: "Original Giver", receiver_email: "giver@email.com", provider: @gift.provider
            template_name = "iom-boomerang-notice-2"
            items_content = items_text(@gift)
            template_content = [
                { "name" => "items_text", "content" => items_content },
                { "name" => "original_receiver", "content" => "giver@email.com"}]
            message_hash = {
                "subject" => "Boomerang! We're returning this gift to you.",
                "from_name" => "ItsOnMe",
                "from_email" => "no-reply@itson.me",
                "to" => [{"email"=>"giver@email.com", "name"=>"Original Giver"}],
                "bcc_address" => "info@itson.me",
                "merge_vars" => [{"rcpt"=>"giver@email.com", "vars"=>[{"name"=>"link", "content"=>"http://0.0.0.0:3001/signup/acceptgift?id=#{NUMBER_ID + boomgift.id}"}]}] }
            data = { "text" => 'notify_receiver_boomerang', "gift_id" => boomgift.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.notify_receiver_boomerang(data)
            d                     = Ditto.last
            d.notable_id.should   == boomgift.id
            d.notable_type.should == 'Gift'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end


    describe :invoice_giver do
        it "should call mandrill with send_template" do
            template_name = "iom-gift-receipt"
            template_content = [{ "name" => "receiver_name", "content" => "Receivy Receiverson" },
                                { "name" => "merchant_name", "content" => "Merchies" },
                                { "name" => "gift_details", "content" => "<ul style='list-style-type:none;'><li>1 Original Margarita </li></ul>" },
                                { "name" => "gift_total", "content" => "100" },
                                { "name" => "service_name", "content" => "ItsOnMe" },
                                { "name" => "user_name", "content" => "Givie Giverson"},
                                { "name" => "processing_fee", "content" => "4" },
                                { "name" => "grand_total", "content" => "104" }]
            message_hash = { "subject" => "Your gift purchase is complete",
                             "from_name" => "ItsOnMe",
                             "from_email" => "no-reply@itson.me",
                             "to" => [{"email"=>"givie@email.com", "name"=>"Givie Giverson"}],
                             "bcc_address" => "info@itson.me",
                             "merge_vars" => [{"rcpt"=>"givie@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}] }
            data = { "text" => 'invoice_giver', "gift_id" => @gift.id }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.invoice_giver(data)
            d                     = Ditto.last
            d.notable_id.should   == @gift.id
            d.notable_type.should == 'Gift'
            d.status.should       == 200
            d.cat.should          == 310
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
                             "to" => [{"email"=>"givie@email.com", "name"=>"Givie Giverson"}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"givie@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}]}
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_gift_giver(@giver, @gift.receiver_name)
            d                     = Ditto.last
            d.notable_id.should   == @giver.id
            d.notable_type.should == 'User'
            d.status.should       == 200
            d.cat.should          == 310
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
                             "to" => [{"email"=>"givie@email.com", "name"=>"Givie Giverson"}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"givie@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}] }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_hasnt_gifted(@giver)
            d                     = Ditto.last
            d.notable_id.should   == @giver.id
            d.notable_type.should == 'User'
            d.status.should       == 200
            d.cat.should          == 310
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
                             "to" => [{"email"=>"receivy@email.com", "name"=>"Receivy Receiverson"}],
                             "bcc_address" => nil,
                             "merge_vars" => [{"rcpt"=>"receivy@email.com", "vars"=>[{"name"=>"link", "content"=>nil}]}]}
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message_hash).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.reminder_gift_receiver(@receiver)
            d                     = Ditto.last
            d.notable_id.should   == @receiver.id
            d.notable_type.should == 'User'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :merchant_pending do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_pending(@merchant)
            template_name    = "merchant"
            template_content = [{ "name" => "body", "content" => body }]
            message          = {
                "subject"     => "QA - Your It's On Me account is pending approval",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => email, "name" => "#{@merchant.name} Staff" }],
                "bcc_address" => "rachel.wenman@itson.me",
                "merge_vars"  => [{
                    "rcpt" => email,
                    "vars" => template_content
                }]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"        => "merchant_pending",
                "email"       => "abe@email.com",
                "merchant_id" => @merchant.id
            }
            MailerJob.merchant_pending(data)
            d                     = Ditto.last
            d.notable_id.should   == @merchant.id
            d.notable_type.should == 'Merchant'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :merchant_invite do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_invite(@merchant, "thetoken")
            template_name    = "merchant"
            template_content = [{ "name" => "body", "content" => body }]
            message          = {
                "subject"     => "QA - Welcome to It's On Me",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => email, "name" => "#{@merchant.name} Staff" }],
                "bcc_address" => "rachel.wenman@itson.me",
                "merge_vars"  => [{
                    "rcpt" => email,
                    "vars" => template_content
                }]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"        => "merchant_invite",
                "email"       => "abe@email.com",
                "merchant_id" => @merchant.id,
                "token"       => "thetoken"
            }
            MailerJob.merchant_invite(data)
            d                     = Ditto.last
            d.notable_id.should   == @merchant.id
            d.notable_type.should == 'Merchant'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :merchant_staff_invite do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_staff_invite(@merchant, "Abe", "thetoken")
            template_name    = "merchant"
            template_content = [{ "name" => "body", "content" => body }]
            message          = {
                "subject"     => "QA - Welcome to It's On Me",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => email, "name" => "#{@merchant.name} Staff" }],
                "bcc_address" => "rachel.wenman@itson.me",
                "merge_vars"  => [{
                    "rcpt" => email,
                    "vars" => template_content
                }]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"        => "merchant_staff_invite",
                "email"       => "abe@email.com",
                "merchant_id" => @merchant.id,
                "token"       => "thetoken",
                "invitor_name" => "Abe"
            }
            MailerJob.merchant_staff_invite(data)
            d                     = Ditto.last
            d.notable_id.should   == @merchant.id
            d.notable_type.should == 'Merchant'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :merchant_approved do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_approved(@merchant)
            template_name    = "merchant"
            template_content = [{ "name" => "body", "content" => body }]
            message          = {
                "subject"     => "QA - You have been Approved!",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => email, "name" => "#{@merchant.name} Staff" }],
                "bcc_address" => "rachel.wenman@itson.me",
                "merge_vars"  => [{
                    "rcpt" => email,
                    "vars" => template_content
                }]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"        => "merchant_approved",
                "email"       => "abe@email.com",
                "merchant_id" => @merchant.id
            }
            MailerJob.merchant_approved(data)
            d                     = Ditto.last
            d.notable_id.should   == @merchant.id
            d.notable_type.should == 'Merchant'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :merchant_live do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_live(@merchant)
            template_name    = "merchant"
            template_content = [{ "name" => "body", "content" => body }]
            message          = {
                "subject"     => "QA - Your location is now live",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => email, "name" => "#{@merchant.name} Staff" }],
                "bcc_address" => "rachel.wenman@itson.me",
                "merge_vars"  => [{
                    "rcpt" => email,
                    "vars" => template_content
                }]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, template_content, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"        => "merchant_live",
                "email"       => "abe@email.com",
                "merchant_id" => @merchant.id
            }
            MailerJob.merchant_live(data)
            d                     = Ditto.last
            d.notable_id.should   == @merchant.id
            d.notable_type.should == 'Merchant'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end    
end
