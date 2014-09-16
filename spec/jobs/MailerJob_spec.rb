require 'spec_helper'
require "mandrill"
include EmailHelper
include ActionView::Helpers::AssetTagHelper

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
            message          = {
                "subject"     => "QA - Reset password request",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [
                    { "email" => @receiver.email, "name" => @receiver.name }
                ],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
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
            link = "#{PUBLIC_URL}/account/confirmemail/#{@receiver.setting.confirm_email_token}"
            body = text_for_user_confirm_email(@receiver, link)
            template_name    = "user"
            message          = {
                "subject" => "QA - Confirm your email address",
                "from_name" => "It's On Me",
                "from_email" => "no-reply@itson.me",
                "to" => [
                    { "email" => @receiver.email, "name" => @receiver.name },
                    { "email" => "info@itson.me", "name" => "info@itson.me", "type" => "bcc" }
                ],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"    => 'confirm_email',
                "user_id" => @receiver.id,
                "link"    => "#{PUBLIC_URL}/account/confirmemail/#{@receiver.setting.confirm_email_token}"
            }
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
                "subject"     => "QA - Please share your feedback",
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

    describe :reminder_hasnt_gifted do
        it "should call mandrill with send_template" do
            body             = text_for_reminder_hasnt_gifted(@giver)
            template_name    = "user"
            message          = {
                "subject"     => "QA - Make someone's day",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => @giver.email, "name" => @giver.name }],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"    => "reminder_hasnt_gifted",
                "user_id" => @giver.id
            }
            MailerJob.reminder_hasnt_gifted(data)
            d                     = Ditto.last
            d.notable_id.should   == @giver.id
            d.notable_type.should == 'User'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :notify_receiver do
        it "should call mandrill with send_template" do
            menu_item = FactoryGirl.create :menu_item
            gift = FactoryGirl.create :gift, receiver_email: @receiver.email, giver_id: @giver.id, giver_type: "User", giver_name: @giver.name, shoppingCart: "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":#{menu_item.id},\"item_name\":\"Original Margarita \"}]"
            body             = text_for_notify_receiver(gift)
            template_name    = "gift"
            message          = {
                "subject"     => "QA - #{ @giver.name } sent you a gift",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => @receiver.email, "name" => @receiver.name }],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"    => 'notify_receiver',
                "gift_id" => gift.id
            }
            MailerJob.notify_receiver(data)
            d                     = Ditto.last
            d.notable_id.should   == gift.id
            d.notable_type.should == 'Gift'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :notify_receiver_boomerang do
        it "should call mandrill with send_template" do
            menu_item = FactoryGirl.create :menu_item
            boomgift = FactoryGirl.create :gift, payable: @gift, receiver_name: "Original Giver", receiver_email: "giver@email.com", provider: @gift.provider, shoppingCart: "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":#{menu_item.id},\"item_name\":\"Original Margarita \"}]"
            template_name = "iom-boomerang-notice-2"
            items_content = items_text(boomgift)
            template_content = [
                { "name" => "items_text", "content" => items_content },
                { "name" => "original_receiver", "content" => "giver@email.com"}]
            message_hash = {
                "subject" => "QA - Boomerang! We're returning this gift to you.",
                "from_name" => "ItsOnMe",
                "from_email" => "no-reply@itson.me",
                "to" => [{"email"=>"giver@email.com", "name"=>"Original Giver"}],
                "bcc_address" => "info@itson.me",
                "merge_vars"  =>[{
                    "rcpt" => "giver@email.com",
                    "vars"=> [{"name"=>"link", "content"=>"http://0.0.0.0:3001/signup/acceptgift?id=#{NUMBER_ID + boomgift.id}"}]
                }]
            }
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

    describe :notify_receiver_proto_join do
        it "should call mandrill with send_template" do
            menu_item = FactoryGirl.create :menu_item
            gift = FactoryGirl.create :gift, receiver_email: @receiver.email, giver_id: @giver.id, giver_type: "User", giver_name: @giver.name, shoppingCart: "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":#{menu_item.id},\"item_name\":\"Original Margarita \"}]"
            body             = text_for_notify_receiver_proto_join(gift)
            template_name    = "gift"
            message          = {
                "subject"     => "QA - The staff at #{ gift.provider_name } sent you a gift",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => @receiver.email, "name" => @receiver.name }],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ],
                "tags" => [ gift.provider_name ]
             }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            data = {
                "text"    => 'notify_receiver_proto_join',
                "gift_id" => gift.id
            }
            MailerJob.notify_receiver_proto_join(data)
            d                     = Ditto.last
            d.notable_id.should   == gift.id
            d.notable_type.should == 'Gift'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :invoice_giver do
        it "should call mandrill with send_template" do
            body             = text_for_invoice_giver(@gift)
            template_name    = "user"
            message          = {
                "subject"     => "QA - Gift purchase receipt",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => @giver.email, "name" => @giver.name }],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
             }
            data = {
                "text" => 'invoice_giver',
                "gift_id" => @gift.id
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
            Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
            MailerJob.invoice_giver(data)
            d                     = Ditto.last
            d.notable_id.should   == @gift.id
            d.notable_type.should == 'Gift'
            d.status.should       == 200
            d.cat.should          == 310
        end
    end

    describe :merchant_invite do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_invite(@merchant, "thetoken")
            template_name    = "merchant"
            message          = {
                "subject"     => "QA - Welcome to It's On Me",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => email, "name" => "#{@merchant.name} Staff" }],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
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
            message          = {
                "subject"     => "QA - Welcome to It's On Me",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [{ "email" => email, "name" => "#{@merchant.name} Staff" }],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
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

    describe :merchant_pending do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_pending(@merchant)
            template_name    = "merchant"
            message          = {
                "subject"     => "QA - Your It's On Me account is pending approval",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [
                    { "email" => email, "name" => "#{@merchant.name} Staff" }
                ],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
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

    describe :merchant_approved do
        it "should call mandrill with send_template" do
            email            = "abe@email.com"
            body             = text_for_merchant_approved(@merchant)
            template_name    = "merchant"
            message          = {
                "subject"     => "QA - You have been Approved!",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [
                    { "email" => email, "name" => "#{@merchant.name} Staff" }
                ],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
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
            message          = {
                "subject"     => "QA - Your location is now live",
                "from_name"   => "It's On Me",
                "from_email"  => "no-reply@itson.me",
                "to"          => [
                    { "email" => email, "name" => "#{@merchant.name} Staff" }
                ],
                "global_merge_vars"  => [
                    { "name" => "body", "content" => body }
                ]
            }
            Mandrill::API.should_receive(:send_template).with(template_name, nil, message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
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
