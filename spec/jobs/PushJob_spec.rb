require 'spec_helper'

describe PushJob do

    describe :perform do

        before(:each) do
            User.delete_all
            PnToken.delete_all
            Provider.delete_all
            @user     = FactoryGirl.create(:user)
            @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token)

        end

        it "should send alias & correct badge to Urban Airship" do
            User.any_instance.stub(:init_confirm_email).and_return(true)
            User.any_instance.stub(:persist_social_data).and_return(true)
            RegisterPushJob.stub(:perform).and_return(true)
            SubscriptionJob.stub(:perform).and_return(true)
            MailerJob.stub(:perform).and_return(true)
            user_alias = @pnt.ua_alias

            prov_name = "Push Testers"
            good_push_hsh = {"aliases" =>["#{user_alias}"],"aps" =>{"alert" => "#{@user.name} sent you a gift at #{prov_name}!","badge"=>1,"sound"=>"pn.wav"},"alert_type"=>1}

            6.times do
                gift = FactoryGirl.create(:gift, receiver: @user, provider_name: "Redeemed", status: 'redeemed')
                redeem = Redeem.create(gift_id: gift.id)
                Order.create(gift_id: gift.id, redeem_id: redeem.id)
            end
            @gift     = FactoryGirl.create(:gift, receiver: @user, provider_name: prov_name)
            run_delayed_jobs
            @gift.reload.receiver.should == @user
            PushJob.should_receive(:format_payload).with(@gift, @user, 1)
            #Urbanairship.should_receive(:push).with(good_push_hsh)

            Relay.send_push_notification @gift
            run_delayed_jobs

        end

    end

end