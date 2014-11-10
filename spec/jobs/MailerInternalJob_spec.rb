require 'spec_helper'
require "mandrill"
include ActionView::Helpers::AssetTagHelper

describe MailerInternalJob do

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

    describe "perform" do
    	before do
            @data = {
            	"subject" => "This is the subject of the email",
            	"text"    => "This is the text of the email and covers all of the important information to communicate",
            	"email"   => ADMIN_NOTICE_CONTACT
            }            		
    	end

        it "should call notify receiver" do
            MailerInternalJob.should_receive(:send_notice).with(@data).and_return(true)
            MailerInternalJob.perform(@data)
        end

        # it "should call mandrill if Mandrill is running in testing env." do
        #     message = {
	       #  	"subject" => @data["subject"],
	       #  	"from_name" => "IOM Database",
	       #  	"text" => @data["text"],
	       #  	"to" => [{
	       #  		"email" => "zo@itson.me",
	       #  		"name" => "IOM Staff (zo@itson.me)"
	       #  	}],
	       #  	"from_email" => NO_REPLY_EMAIL
        #     }         
        #     Mandrill::API.should_receive(:send).with(message).and_return( [{"email"=>"busseyt2@unlv.nevada.edu", "status"=>"sent", "_id"=>"55f14c81146947de96c19e8d5358ec61", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"74d1094af918424dbaa6721a36e6bfa9", "reject_reason"=>nil}])
        #     Mandrill::API.stub_chain(:new, :messages){ Mandrill::API }
        #     MailerInternalJob.send_notice(@data)
        # end

    end

end
