require 'spec_helper'

describe Email do

    describe :notify_receiver do

        xit "should BS" do
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})

            @user     = FactoryGirl.create(:user)
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @card     = FactoryGirl.create(:card, name: @user.name, user_id: @user.id)
            @provider = FactoryGirl.create(:provider)
            ResqueSpec.reset!
            WebMock.reset!

            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            gift = FactoryGirl.create(:gift)
            run_delayed_jobs
            abs_gift_id = response.id + NUMBER_ID
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-notify-receiver"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\/#{abs_gift_id}/)
                else
                    true
                end
            }.twice
        end

        it "should not send notify receiver emails when new gift settings is false" do
            gift = FactoryGirl.create(:gift)
            ResqueSpec.reset!
            WebMock.reset!
            gift.notify_receiver
            run_delayed_jobs
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-notify-receiver"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\/#{abs_gift_id}/)
                else
                    true
                end
            }.twice
        end
    end
end