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
            @gift     = FactoryGirl.create :gift, receiver: @user
        end

        context "notify gift receiver on create" do

            it "should receive correct push message" do
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