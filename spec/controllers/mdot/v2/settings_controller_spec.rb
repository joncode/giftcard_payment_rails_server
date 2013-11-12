require 'spec_helper'

describe Mdot::V2::SettingsController do

    before(:each) do
        User.delete_all
        Setting.delete_all
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        it "should get the users settings and return json" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            keys    =  ["email_follow_up", "email_invite", "email_invoice", "email_receiver_new", "email_redeem", "user_id"]
            rrc(200)
            hsh = json["data"]
            hsh.class.should == Hash
            compare_keys(hsh, keys)
        end
    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update)

        it "should receive json'd settings and update the record" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: "{  \"email_receiver_new\" : \"false\",  \"email_invite\" : \"false\",  \"email_redeem\" : \"false\",  \"email_invoice\" : \"false\",  \"email_follow_up\" : \"false\"}"
            rrc(200)
            json["status"].should == 1
            json["data"].should        == "Settings saved"
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
            json["data"].should        == "Settings saved"
            setting.reload
            setting.email_invoice.should be_true
            setting.email_redeem.should be_true
            setting.email_invite.should be_true
            setting.email_follow_up.should be_true
            setting.email_receiver_new.should be_true
        end

        it "should receive non-json'd settings and update the record" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"email_receiver_new"=>false, "email_invite"=>false, "email_redeem"=>false, "email_invoice"=>false, "email_follow_up"=>false}
            put :update, format: :json, data: params
            rrc(200)
            json["status"].should == 1
            json["data"].should   == "Settings saved"
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
            json["data"].should        == "Settings saved"
            setting.reload
            setting.email_invoice.should be_true
            setting.email_redeem.should be_true
            setting.email_invite.should be_true
            setting.email_follow_up.should be_true
            setting.email_receiver_new.should be_true
        end

        it "should not accept false keys and succeed silently" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = {"email_receisdf"=>false, "email_invite"=>false, "email_rsadfedeem"=>false, "ads"=>false, "sdf"=>true}
            put :update, format: :json, data: params
            rrc(200)
            json["status"].should == 1
            json["data"].should   == "Settings saved"
            @user.reload
            setting = @user.setting
            setting.email_invite.should be_false
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
