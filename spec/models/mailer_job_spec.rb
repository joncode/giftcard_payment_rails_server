require 'spec_helper'

describe MailerJob do

    it "should call mandrill" do

        @gift = FactoryGirl.create :gift
        @gift_item = FactoryGirl.create :gift_item, { gift_id: @gift.id }
    	@user = FactoryGirl.create :user, {first_name: "bob", last_name:"barker"}
        data = {"text"     => 'notify_receiver',
                "gift_id"  =>  @gift.id}
        require "mandrill"
        Mandrill::API.should_receive(:new)
    	
    	MailerJob.perform(data)
    end

end