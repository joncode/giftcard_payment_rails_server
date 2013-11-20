require 'spec_helper'
require 'mandrill'

describe IphoneController do

    describe :update_photo do

        before(:each) do
            User.delete_all
        end

        context "authorization" do

            it "should not allow unauthenticated access" do
                post :update_photo, format: :json, token: "No Way Entrance"
                rrc_old(200)

                json["error"].should  == "Data error, please log out and log back to reset system"
            end

        end

        let(:user) { FactoryGirl.create(:user) }

        it "should not run method when user is not found" do
            params_data = "{\"iphone_photo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            post :update_photo, data: params_data, format: :json
            rrc_old(200)
            json["error"].should   == "Data error, please log out and log back to reset system"
            json.keys.count.should == 1
        end

        it "should require an 'iphone_photo' key" do
            params_data = "{\"phoo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            rrc_old(200)
            json["error"].should   == "Photo upload failed, please check your connetion and try again"

        end

        it "should update 'iphone_photo' and 'user_photo'" do
            params_data = "{\"iphone_photo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            photo_pre   = "http://res.cloudinary.com/drinkboard/image/upload/v1382464405/myg7nfaccypfaybffljo.jpg"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            user_new = User.last
            user_new.use_photo.should    == 'ios'
            user_new.iphone_photo.should == photo_pre
            user_new.get_photo.should    == photo_pre
        end

        it "should return success msg when success" do
            params_data = "{\"iphone_photo\" : \"http:\\/\\/res.cloudinary.com\\/drinkboard\\/image\\/upload\\/v1382464405\\/myg7nfaccypfaybffljo.jpg\"}"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            rrc_old(200)
            json["success"].should   == "Photo Updated - Thank you!"

        end

        it "should send fail msgs when error" do
            params_data = "{\"iphone_photo\" : null }"
            post :update_photo, data: params_data, format: :json, token: user.remember_token
            rrc_old(200)
            json["error"].should   == "Photo upload failed, please check your connetion and try again"
        end

    end

    describe :create_account do

        context "authorization" do

            xit "should not allow unauthenticated access" do
                post :create_account, format: :json, token: "No Way Entrance"
                rrc_old(200)
                json["error"].should  == "Data error, please log out and log back to reset system"
            end

        end

        context "external service tests" do

            it "should hit mailchimp endpoint with correct email for subscription" do
                ResqueSpec.reset!
                RegisterPushJob.stub(:perform).and_return(true)
                MailerJob.stub(:call_mandrill).and_return(true)
                User.any_instance.stub(:init_confirm_email).and_return(true)
                #Resque.should_receive(:enqueue).with(SubscriptionJob, anything)
                #SubscriptionJob.should_receive(:perform).with(anything)
                #MailchimpList.stub(:new) { MailchimpList }
                MailchimpList.any_instance.should_receive(:subscribe).and_return({"email" => "neil@gmail.com" })

                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
                run_delayed_jobs

                user = UserSocial.find_by(identifier: "neil@gmail.com")
                user.subscribed.should be_true
            end

            it "should hit mandrill endpoint with correct email for confirm email w/o pn_token" do
                User.any_instance.stub(:persist_social_data).and_return(true)
                RegisterPushJob.stub(:perform).and_return(true)
                SubscriptionJob.stub(:perform).and_return(true)
                Mandrill::API.stub_chain(:new, :messages) { Mandrill::API }
                Mandrill::API.should_receive(:send_template).with("confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"no-reply@itson.me", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"info@itson.me", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})


                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
                run_delayed_jobs
            end


            it "should hit mandrill endpoint with correct email for confirm email w/ pn_token" do
                Urbanairship.stub(:register_device).and_return("pn_token", { :alias => "ua_alias"})
                User.any_instance.stub(:persist_social_data).and_return(true)
                SubscriptionJob.stub(:perform).and_return(true)
                RegisterPushJob.stub(:perform).and_return(true)
                Mandrill::API.stub_chain(:new, :messages) { Mandrill::API }
                Mandrill::API.should_receive(:send_template).with("confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"no-reply@itson.me", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"info@itson.me", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})

                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh, pn_token: "FAKE_PN_TOKENFAKE_PN_TOKEN"
                run_delayed_jobs
            end

            it "should hit urban airship endpoint with correct token and alias" do
                User.any_instance.stub(:ua_alias).and_return("fake_ua")
                User.any_instance.stub(:pn_token).and_return("FAKE_PN_TOKENFAKE_PN_TOKEN")
                User.any_instance.stub(:persist_social_data).and_return(true)
                User.any_instance.stub(:init_confirm_email).and_return(true)
                SubscriptionJob.stub(:perform).and_return(true)
                MailerJob.stub(:call_mandrill).and_return(true)
                pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
                ua_alias = "fake_ua"

                Urbanairship.should_receive(:register_device).with(pn_token, { :alias => ua_alias})
                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh, pn_token: pn_token
                run_delayed_jobs # ResqueSpec.perform_all(:push)
            end
        end

        it "should create user with required fields" do
            email = "neil@gmail.com"
            user_hsh = { "email" =>  email, password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            user = User.where(email: email).first
            user.first_name.should == "Neil"
        end

        it "should process optional fields" do
            optional = [ "last_name" ,"phone", "twitter", "facebook_id", "origin", "iphone_photo", "use_photo", "handle"]
            requests = [{"first_name"=>"Rushit", "use_photo"=>"ios", "password"=>"hotmail007", "last_name"=>"Patel", "phone"=>"5107543267", "email"=>"rdpatel007@gmail.com", "origin"=>"d", "iphone_photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/1076106_637557363_1453430141_n.jpg", "password_confirmation"=>"hotmail007", "facebook_id"=>637557363},
            {"first_name"=>"Kathryn", "use_photo"=>"ios", "password"=>"Emachines4", "last_name"=>"Sell", "phone"=>"9517959756", "email"=>"Caligirlkaty@gmail.com", "origin"=>"d", "iphone_photo"=>"http://graph.facebook.com/100004277051506/picture?type=large", "password_confirmation"=>"Emachines4", "facebook_id"=>"100004277051506"},
            {"first_name"=>"Alicia", "use_photo"=>"ios", "password"=>"clippers50", "last_name"=>"Rivera", "phone"=>"7149288304", "email"=>"shashas79@yahoo.com", "origin"=>"d", "iphone_photo"=>"http://graph.facebook.com/1045433036/picture?type=large", "password_confirmation"=>"clippers50", "facebook_id"=>"1045433036"},
            {"first_name"=>"Austen", "use_photo"=>"ios", "password"=>"Tokujiro3", "last_name"=>"Debord", "phone"=>"3607736866", "email"=>"Austen.debord@gmail.com", "origin"=>"d", "iphone_photo"=>"http://graph.facebook.com/818275441/picture?type=large", "password_confirmation"=>"Tokujiro3", "facebook_id"=>"818275441"},
            {"use_photo"=>"ios", "password"=>"princess07", "twitter"=>"119536306", "origin"=>"d", "facebook_id"=>40200220, "password_confirmation"=>"princess07", "last_name"=>"Kimenker", "email"=>"ashlik07@gmail.com", "iphone_photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/1086486_40200220_406591072_n.jpg", "phone"=>"7027547538", "first_name"=>"Ashli", "handle"=>"@LVAshli"},
            {"first_name"=>"Brianna", "use_photo"=>"ios", "password"=>"special1", "last_name"=>"Clater", "phone"=>"6193685354", "email"=>"bclater@gmail.com", "origin"=>"d", "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"special1"},
            {"first_name"=>"Ruby", "use_photo"=>"ios", "password"=>"isabel123", "last_name"=>"Romero", "phone"=>"7022757785", "email"=>"rubyromero.702@gmail.com", "origin"=>"d", "iphone_photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/1076738_1168689876_1696701385_n.jpg", "password_confirmation"=>"isabel123", "facebook_id"=>1168689876},
            {"first_name"=>"Emily", "use_photo"=>"ios", "password"=>"dietcoke05", "last_name"=>"Higashi", "phone"=>"8056306555", "email"=>"Emilyhigashi@yahoo.com", "origin"=>"d", "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"dietcoke05"},
            {"first_name"=>"Chuu", "use_photo"=>"ios", "password"=>"torokeru", "last_name"=>"Toro", "phone"=>"4158713828", "email"=>"Toro.chuu@gmail.com", "origin"=>"d", "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"torokeru"},
            {"first_name"=>"Amanda", "use_photo"=>"ios", "password"=>"iluv220", "last_name"=>"Stein", "email"=>"Asc220@comcast.net", "origin"=>"d", "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"iluv220"},
            {"first_name"=>"Kevin", "use_photo"=>"ios", "password"=>"kevinn", "last_name"=>"Novak", "phone"=>"7343950489", "email"=>"kevin@uber.com", "origin"=>"d", "iphone_photo"=>"http://graph.facebook.com/28700910/picture?type=large", "password_confirmation"=>"kevinn", "facebook_id"=>"28700910"}]
            requests.each do |req_hsh|
                post :create_account, format: :json, token: GENERAL_TOKEN, data: req_hsh, pn_token: "8c5c69870825e3255bc750395f9b0680b54f458e93322109853567c85d17d48b"
                rrc_old(200)
                json_resp = JSON.parse(response.body)
                user_id = json_resp["success"]["user_id"]
                user = User.find(user_id)
                user.class.should == User
                req_hsh['email'] = req_hsh['email'].downcase
                req_hsh.each_key do |key|
                    if (key != "password") && (key != "password_confirmation")
                        user.send(key).should == req_hsh[key].to_s

                    end
                end
            end
        end

        it "should return 'user_id' and 'token' on success" do
            email = "neil@gmail.com"
            user_hsh = { "email" =>  email, password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            keys = ["user_id", "token"]
            hsh  = json["success"]
            compare_keys(hsh, keys)
            user = User.where(email: email).first
            json["success"]["user_id"].should == user.id
            json["success"]["token"].should   == user.remember_token
        end

        it "should not accept missing / invalid required fields" do
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password", first_name: ""}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password", first_name: nil}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password" }
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "passasdfword", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: nil, first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: "passasdfword" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: "" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: nil , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "neimail.com", password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  "", password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { "email" =>  nil, password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
            user_hsh = { password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            rrc_old(200)
            json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
        end

        it "should not accept requests without user_hash" do
            user_hsh = { password: "password" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN
            rrc_old(200)
            #json.has_key?("error_server").should be_true
            json.has_key?("success").should be_false
        end

        xit "should not return 'password digest' validation fail" do
           user_hsh = { "email" =>  "neil@gmail.com", password: "" , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            json["error_server"].has_key?("password_digest").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: nil , password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            json["error_server"].has_key?("password_digest").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password_confirmation: "password", first_name: "Neil"}
            post :create_account, format: :json, token: GENERAL_TOKEN, data: user_hsh
            json["error_server"].has_key?("password_digest").should be_false
        end
    end

end




















