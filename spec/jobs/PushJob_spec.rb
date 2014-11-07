require 'spec_helper'

include MocksAndStubs

describe PushJob do

    describe :perform do

        before(:each) do
            User.delete_all
            PnToken.delete_all
            Provider.delete_all
            @user     = FactoryGirl.create(:user)
            @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            RegisterPushJob.stub(:ua_register)
            @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token)
            resque_stubs
        end

        context "notify gift receiver on create" do

            it "should send alias & correct badge to Urban Airship" do
                ResqueSpec.reset!
                user_alias = @pnt.ua_alias
                prov_name  = "Push Testers"

                6.times do
                # these shold not go to push badge count
                    gift       = FactoryGirl.create(:gift, receiver: @user, provider_name: "Notified")
                    gift.notify
                end
                @gift      = FactoryGirl.create(:gift, receiver: @user, provider_name: prov_name)

                alert = "#{@gift.giver_name} sent you a gift at #{prov_name}!"
                good_push_hsh   = {
                    :aliases => [@pnt.ua_alias],
                    :aps => {
                        :alert => alert,
                        :badge => 1,
                        :sound => 'pn.wav'
                    },
                    :alert_type => 1,
                    :android => {
                        :alert => alert
                    }
                }

                run_delayed_jobs
                @gift.reload.receiver.should == @user

                Urbanairship.should_receive(:push).with(good_push_hsh).and_return({"push_id"=>"39f42812-0665-11e4-bc49-90e2ba272c68"})

                Relay.send_push_notification @gift
                run_delayed_jobs
                d                     = Ditto.last
                d.notable_id.should   == @gift.id
                d.notable_type.should == 'Gift'
                d.status.should       == 200
                d.cat.should          == 110
            end

        end

        context "notify gift giver when gift is opened" do

            it "should notify the giver when the gift is opened" do
                prov_name = "Pusher's"
                receiver = FactoryGirl.create(:receiver)
                @gift     = FactoryGirl.create(:gift, giver: @user, receiver: receiver, provider_name: prov_name)
                3.times do
                    gifts = FactoryGirl.create(:gift, receiver: @user)
                end
                user_alias      = @pnt.ua_alias
                alert           = "#{@gift.receiver_name} opened your gift at #{prov_name}!"
                good_push_hsh   = {
                    :aliases => [@pnt.ua_alias],
                    :aps => {
                        :alert => alert,
                        :badge => 3,
                        :sound => 'pn.wav'
                    },
                    :alert_type => 2,
                    :android => {
                        :alert => alert
                    }
                }

                Urbanairship.should_receive(:push).with(good_push_hsh).and_return({"push_id"=>"39f42812-0665-11e4-bc49-90e2ba272c68"})
                PushJob.perform(@gift.id, true)
                d                     = Ditto.last
                d.notable_id.should   == @gift.id
                d.notable_type.should == 'Gift'
                d.status.should       == 200
                d.cat.should          == 110
            end
        end

        context "notify gift giver when incomplete gift gets connected" do

            it "should notify the giver when an incomplete gift is connected" do
                prov_name = "Pusher's"
                receiver  = FactoryGirl.build(:receiver)
                @gift     = FactoryGirl.create(:gift, giver: @user, receiver_name: receiver.name, receiver_email: receiver.email, provider_name: prov_name)
                @gift.status.should == 'incomplete'
                user_alias = @pnt.ua_alias
                alert = "Thank You! #{@gift.receiver_name} got the app and your gift!"

                good_push_hsh   = {
                    :aliases => [@pnt.ua_alias],
                    :aps => {
                        :alert => alert,
                        :badge => 0,
                        :sound => 'pn.wav'
                    },
                    :alert_type => 2,
                    :android => {
                        :alert => alert
                    }
                }

                Urbanairship.should_receive(:push).with(good_push_hsh)
                PushJob.perform(@gift.id, true, true)
            end

        end

        context "BizUser gift" do

            it "should not send a push to biz users" do
                prov_name = "Pusher's"
                receiver = FactoryGirl.create(:receiver)
                provider = FactoryGirl.create(:provider)
                biz_user = provider.biz_user
                @gift     = FactoryGirl.create(:gift, giver: biz_user, receiver: receiver, provider_name: prov_name)
                3.times do
                    gifts = FactoryGirl.create(:gift, receiver: @user)
                end
                alert      = "#{@gift.receiver_name} opened your gift at #{prov_name}!"
                good_push_hsh   = {
                    :aliases => [@pnt.ua_alias],
                    :aps => {
                        :alert => alert,
                        :badge => 3,
                        :sound => 'pn.wav'
                    },
                    :alert_type => 2,
                    :android => {
                        :alert => alert
                    }
                }

                Urbanairship.should_not_receive(:push).with(good_push_hsh)
                PushJob.perform(@gift.id, true)
            end
        end
    end

    context "Android Device" do

        before(:each) do
            User.delete_all
            PnToken.delete_all
            Provider.delete_all
             RegisterPushJob.stub(:ua_register)
        end

        it "should send correct payload on push" do
            user      = FactoryGirl.create :user
            droid_pnt = PnToken.create(user_id: user.id, pn_token: "DROIDPN_TOKENFAKE_PN_TOKEN", platform: "android")
            gift      = FactoryGirl.create :gift, receiver: user
            badge     = Gift.get_notifications(user)
            alert     = "#{gift.giver_name} sent you a gift at #{gift.provider_name}!"
            payload   = {
                :aliases => [user.ua_alias],
                :aps => {
                    :alert => alert,
                    :badge => badge,
                    :sound => 'pn.wav'
                },
                :alert_type => 1,
                :android => {
                    :alert => alert
                }
            }
            Urbanairship.should_receive(:push).with(payload)
            PushJob.perform(gift.id)
        end

        it "should send correct payload to both ios and android" do
            user      = FactoryGirl.create :user
            droid_pnt = PnToken.create(user_id: user.id, pn_token: "DROIDPN_TOKENFAKE_PN_TOKEN", platform: "android")
            ios_pnt   = PnToken.create(user_id: user.id, pn_token: "IOSIDPN_TOKENFAKE_PN_TOKEN", platform: "ios")
            gift      = FactoryGirl.create :gift, receiver: user
            badge     = Gift.get_notifications(user)
            alert     = "#{gift.giver_name} sent you a gift at #{gift.provider_name}!"
            payload   = {
                :aliases => [user.ua_alias],
                :aps => {
                    :alert => alert,
                    :badge => badge,
                    :sound => 'pn.wav'
                },
                :alert_type => 1,
                :android => {
                    :alert => alert
                }
            }
            Urbanairship.should_receive(:push).with(payload)
            PushJob.perform(gift.id)
        end

        it "should send correct payload on thank you push" do
            giver     = FactoryGirl.create :user
            droid_pnt = PnToken.create(user_id: giver.id, pn_token: "DROIDPN_TOKENFAKE_PN_TOKEN", platform: "android")
            gift      = FactoryGirl.create :gift, giver: giver
            badge     = Gift.get_notifications(giver)
            alert     = "#{gift.receiver_name} opened your gift at #{gift.provider.name}!"
            payload   = {
                :aliases => [giver.ua_alias],
                :aps => {
                    :alert => alert,
                    :badge => badge,
                    :sound => 'pn.wav'
                },
                :alert_type => 2,
                :android => {
                    :alert => alert
                }
            }
            Urbanairship.should_receive(:push).with(payload)
            PushJob.perform(gift.id, true)
        end

        it "should send correct payload on incomplete gift push" do
            giver     = FactoryGirl.create :user
            droid_pnt = PnToken.create(user_id: giver.id, pn_token: "DROIDPN_TOKENFAKE_PN_TOKEN", platform: "android")
            gift      = FactoryGirl.create :gift, giver: giver
            badge     = Gift.get_notifications(giver)
            alert     = "Thank You! #{gift.receiver_name} got the app and your gift!"
            payload   = {
                :aliases => [giver.ua_alias],
                :aps => {
                    :alert => alert,
                    :badge => badge,
                    :sound => 'pn.wav'
                },
                :alert_type => 2,
                :android => {
                    :alert => alert
                }
            }
            Urbanairship.should_receive(:push).with(payload)
            PushJob.perform(gift.id, true, true)
        end
    end

end
