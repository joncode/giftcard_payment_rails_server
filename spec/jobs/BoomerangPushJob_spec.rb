require 'spec_helper'

describe PushJob do

    describe :perform do

        before(:each) do
        end

        context "notify gift receiver on create" do
            it "should receive correct push message" do
            User.delete_all
            PnToken.delete_all
            Provider.delete_all
            @user     = FactoryGirl.create(:user)
            @pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            stub_request(:put, "https://q_NVI6G1RRaOU49kKTOZMQ:yQEhRtd1QcCgu5nXWj-2zA@go.urbanairship.com/api/device_tokens/#{@pn_token}").with(:body => "{\"alias\":\"#{@user.ua_alias}\",\"provider\":\"ios\"}", :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
            @pnt      = PnToken.create(user_id: @user.id, pn_token: @pn_token)
            @gift     = FactoryGirl.create :gift, receiver: @user
                alert = "Boomerang! We are returning this gift to you because your friend never created an account"
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

                Urbanairship.should_receive(:push).with(good_push_hsh).and_return({"push_id"=>"39f42812-0665-11e4-bc49-90e2ba272c68"})
                BoomerangPushJob.perform @gift.id
            end

        end
    end
end