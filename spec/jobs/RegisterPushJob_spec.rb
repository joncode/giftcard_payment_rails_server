require 'spec_helper'
include MocksAndStubs

describe RegisterPushJob do

    describe :perform do

        it "should send register android and ios to correct respective route" do
            @user     = FactoryGirl.create(:user)
            platform = :android
            test_urban_airship_endpoint(platform) do |pn_token|
                PnToken.create(user_id: @user.id, pn_token: pn_token, platform: platform)
            end
        end

        it "should create a ditto for register device" do
            @user     = FactoryGirl.create(:user)
            platform = :android
            test_urban_airship_endpoint(platform) do |pn_token|
                PnToken.create(user_id: @user.id, pn_token: pn_token, platform: platform)
            end
            d = Ditto.last
            d.notable_type.should == "User"
            d.notable_id.should   == @user.id
        end
    end
end