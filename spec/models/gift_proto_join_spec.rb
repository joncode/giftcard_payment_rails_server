require 'spec_helper'

include ProtoFactory

describe GiftProtoJoin do

    before(:each) do
        proto_with_socials 1
        @pj         = ProtoJoin.where(receivable_type: "Social").first
        @gift_hsh  = { 'proto_join' => @pj }
    end

    describe :create do

        it_should_behave_like "gift serializer" do
            let(:object) { GiftProtoJoin.create(@gift_hsh) }
        end

        it "should accept a proto or/and proto join" do
            expect {GiftProtoJoin.create({ 'proto_join' => @pj }) }.to_not raise_error
            proto = Proto.first
            expect {GiftProtoJoin.create({ 'proto' => proto }) }.to raise_error
        end

        it "should raise error if neither proto or proto_join" do
            expect { GiftProtoJoin.create({ 'proto_type' => 102, 'receiver' => 'test receiger' }) }.to raise_error
        end

        it "should create and return gift for social" do
            proto = @pj.proto
            gift_proto = GiftProtoJoin.create(@gift_hsh)
            gift_proto.class.should    == GiftProtoJoin
            gift_proto.should be_valid
            gift       = Gift.find(gift_proto.id)
            gift.class.should          == Gift
            gift.detail.should         == proto.detail
            gift.message.should        == proto.message
            gift.receiver_name.should  == GENERIC_RECEIVER_NAME
            gift.provider_id.should    == proto.provider_id
            gift.provider_name.should  == proto.provider_name
        end

        it "should create and return gift for user" do
            proto_with_users 1
            pj         = ProtoJoin.where(receivable_type: "User").first
            gift_hsh  = { 'proto_join' => pj }
            proto = pj.proto
            user  = pj.receivable
            gift_proto = GiftProtoJoin.create(gift_hsh)
            gift_proto.class.should    == GiftProtoJoin
            gift_proto.should be_valid
            gift       = Gift.find(gift_proto.id)
            gift.class.should          == Gift
            gift.detail.should         == proto.detail
            gift.message.should        == proto.message
            gift.receiver_name.should  == user.name
            gift.receiver_id.should    == user.id
            gift.provider_id.should    == proto.provider_id
            gift.provider_name.should  == proto.provider_name
        end

        it "should update the proto join gift ID when success" do
            gift_proto = GiftProtoJoin.create(@gift_hsh)
            @pj.reload
            @pj.gift_id.should == gift_proto.id
        end
    end

    context "messaging" do

        before(:each) do
            ResqueSpec.reset!
            WebMock.reset!
        end

        it "should not email invoice to the sender" do
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            response = GiftProtoJoin.create @gift_hsh

            run_delayed_jobs
            abs_gift_id = response.id + NUMBER_ID

            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-gift-receipt"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\/#{abs_gift_id}/)
                else
                    true
                end

            }.once
        end

        it "should email notify the recipient" do
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            response = GiftProtoJoin.create @gift_hsh
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
            }.once
        end

        it "should push notify to app-user recipients" do
            proto_with_users 1
            pj        = ProtoJoin.where(receivable_type: "User").first
            gift_hsh  = { 'proto_join' => pj }
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            good_push_hsh = {:aliases =>["#{pj.receivable.ua_alias}"],:aps =>{:alert => "#{pj.proto.giver.name} sent you a gift at #{pj.proto.provider_name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            gift = GiftProtoJoin.create gift_hsh
            gift.receiver_id.should == pj.receivable.id
            run_delayed_jobs
        end
    end
end





#         # it "should not message users when payment_error" do
#         #     stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
#         #     stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
#         #     good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@biz_user.name} sent you a gift",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
#         #     Urbanairship.should_not_receive(:push).with(good_push_hsh)
#         #     GiftProtoJoin.create @gift_hsh
#         #     run_delayed_jobs
#         # end

#     end
# end
