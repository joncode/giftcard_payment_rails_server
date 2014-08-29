require 'spec_helper'
require 'cron'
include Cron

describe "Cron" do

    describe :register_missing_pn_tokens do
        it "should go through urban_airship_wrap" do
            user = FactoryGirl.create :user
            pn_token = FactoryGirl.create :pn_token, user_id: user.id, pn_token: "thisisthetokenandshouldbeverylong", platform: "ios"
            ua_tokens = [{ "device_token" => "11111" }]
            Urbanairship.should_receive(:device_tokens_with_limiting).and_return(ua_tokens)
            Ditto.should_receive(:tokens_push_create).with(ua_tokens).and_return(true)
            Urbanairship.should_receive(:register_device).and_return("ua_register_response")
            Ditto.should_receive(:register_push_create).with("ua_register_response", user.id).and_return(true)
            register_missing_pn_tokens
        end
    end

    describe :check_update_aliases do
    	it "should go through urban_airship_wrap" do
	    	user = FactoryGirl.create :user
	    	pn_token = FactoryGirl.create :pn_token, user_id: user.id, pn_token: "thisisthetokenandshouldbeverylong", platform: "ios"
            ua_tokens = [{ "device_token" => "11111" }]
	    	Urbanairship.should_receive(:device_tokens_with_limiting).and_return(ua_tokens)
            Ditto.should_receive(:tokens_push_create).with(ua_tokens).and_return(true)
	    	check_update_aliases
	    end

        it "should unregister and reregister if pn aliases don't match" do
            user = FactoryGirl.create :user
            pn_token = FactoryGirl.create :pn_token, user_id: user.id, pn_token: "thisisthetokenandshouldbeverylong", platform: "ios"
            ua_tokens = [{
                "device_token" => "thisisthetokenandshouldbeverylong",
                "alias" => "wrongalias"
            }]
            Urbanairship.should_receive(:device_tokens_with_limiting).and_return(ua_tokens)
            Ditto.should_receive(:tokens_push_create).with(ua_tokens).and_return(true)

            Urbanairship.should_receive(:unregister_device).and_return("ua_register_response")
            Ditto.should_receive(:unregister_push_create).with("ua_register_response", user.id).and_return(true)

            Urbanairship.should_receive(:register_device).and_return("ua_register_response")
            Ditto.should_receive(:register_push_create).with("ua_register_response", user.id).and_return(true)

            check_update_aliases
        end

        it "should NOT unregister and register if pn tokens match" do
            user = FactoryGirl.create :user
            pn_token = FactoryGirl.create :pn_token, user_id: user.id, pn_token: "thisisthetokenandshouldbeverylong", platform: "ios"
            ua_tokens = [{
                "device_token" => "thisisthetokenandshouldbeverylong",
                "alias" => "user-#{user.id + NUMBER_ID}"
            }]
            Urbanairship.should_receive(:device_tokens_with_limiting).and_return(ua_tokens)
            Ditto.should_receive(:tokens_push_create).with(ua_tokens).and_return(true)

            Urbanairship.should_not_receive(:unregister_device)
            Urbanairship.should_not_receive(:register_device)

            check_update_aliases
        end

    end

end