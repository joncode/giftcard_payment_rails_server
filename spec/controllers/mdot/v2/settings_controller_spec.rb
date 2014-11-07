require 'spec_helper'

include UserSessionFactory

describe Mdot::V2::SettingsController do

    before(:each) do
        User.delete_all
        Setting.delete_all
        @user = create_user_with_token "USER_TOKEN"
        @keys = ["email_follow_up", "email_invite", "email_invoice", "email_receiver_new", "email_redeem", "user_id", "email_reminder_gift_receiver", "email_reminder_gift_giver"]
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        it "should get the users settings and return json" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            hsh = json["data"]
            hsh.class.should == Hash
            compare_keys(hsh, @keys)
        end
    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update)

        it "should receive json'd settings and update the record" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: "{  \"email_receiver_new\" : \"false\",  \"email_invite\" : \"false\",  \"email_redeem\" : \"false\",  \"email_invoice\" : \"false\",  \"email_follow_up\" : \"false\"}"
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            compare_keys(response, @keys)
            setting = @user.setting
            setting.reload
            setting.email_invoice.should be_false
            setting.email_redeem.should be_false
            setting.email_invite.should be_false
            setting.email_follow_up.should be_false
            setting.email_receiver_new.should be_false
            put :update, format: :json, data: "{  \"email_receiver_new\" : \"true\",  \"email_invite\" : \"true\",  \"email_redeem\" : \"true\",  \"email_invoice\" : \"true\",  \"email_follow_up\" : \"true\"}"
            rrc(200)
            json["status"].should == 1
            compare_keys(response, @keys)
            setting.reload
            setting.email_invoice.should be_true
            setting.email_redeem.should be_true
            setting.email_invite.should be_true
            setting.email_follow_up.should be_true
            setting.email_receiver_new.should be_true
        end

        it "should receive json'd gift email settings and update the record" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: "{  \"email_reminder_gift_receiver\" : \"false\",  \"email_reminder_gift_giver\" : \"false\"}"
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            compare_keys(response, @keys)
            setting = @user.setting
            setting.reload
            setting.email_reminder_gift_receiver.should be_false
            setting.email_reminder_gift_giver.should be_false
            put :update, format: :json, data: "{  \"email_reminder_gift_receiver\" : \"true\",  \"email_reminder_gift_giver\" : \"true\"}"
            rrc(200)
            json["status"].should == 1
            compare_keys(response, @keys)
            setting.reload
            setting.email_reminder_gift_receiver.should be_true
            setting.email_reminder_gift_giver.should be_true
        end

        it "should receive non-json'd settings and update the record" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"email_receiver_new"=>false, "email_invite"=>false, "email_redeem"=>false, "email_invoice"=>false, "email_follow_up"=>false}
            put :update, format: :json, data: params
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            compare_keys(response, @keys)
            setting = @user.setting
            setting.reload
            setting.email_invoice.should be_false
            setting.email_redeem.should be_false
            setting.email_invite.should be_false
            setting.email_follow_up.should be_false
            setting.email_receiver_new.should be_false
            params = {"email_receiver_new"=>true, "email_invite"=>true, "email_redeem"=>true, "email_invoice"=>true, "email_follow_up"=>true}
            put :update, format: :json, data: params
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            compare_keys(response, @keys)
            setting.reload
            setting.email_invoice.should be_true
            setting.email_redeem.should be_true
            setting.email_invite.should be_true
            setting.email_follow_up.should be_true
            setting.email_receiver_new.should be_true
        end

        it "should receive non-json'd gift email settings and update the record" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = { "email_reminder_gift_receiver" => false, "email_reminder_gift_giver" => false }
            put :update, format: :json, data: params
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            compare_keys(response, @keys)
            setting = @user.setting
            setting.reload
            setting.email_reminder_gift_receiver.should be_false
            setting.email_reminder_gift_giver.should be_false
            params = { "email_reminder_gift_receiver" => true, "email_reminder_gift_giver" => true }
            put :update, format: :json, data: params
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            compare_keys(response, @keys)
            setting.reload
            setting.email_reminder_gift_receiver.should be_true
            setting.email_reminder_gift_giver.should be_true
        end

        it "should not update record keys that are not accesible" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params =  {created_at: "happy", updated_at: "happy", confirm_email_token: "happy", confirm_phone_token: "happy", reset_token: "happy", confirm_phone_flag: "happy", confirm_email_flag: "happy", confirm_phone_token_sent_at: "happy", confirm_email_token_sent_at: "happy", reset_token_sent_at: "happy"}
            put :update, format: :json, data: params
            rrc(400)
        end

        it "should reject non hashes and non JSON hashes" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params =  ["happy", "happy"]
            put :update, format: :json, data: params
            rrc(400)
            params =  "Hey Dude fake "
            put :update, format: :json, data: params
            rrc(400)
        end

    end


end
