require 'spec_helper'
require 'mandrill'

include UserSessionFactory

describe Mdot::V2::UsersController do

    before(:each) do
        User.delete_all
        #User.any_instance.stub(:init_confirm_email).and_return(true)
        @user = create_user_with_token "USER_TOKEN"
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        before(:each) do
            20.times do |index|
                FactoryGirl.create(:user, first_name: "Newbiee#{index}")
            end
            user = User.last
            user.update_attribute(:active, false)
        end

        it "should return a list of active users" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            amount  = User.where(active: true).where(active: true).count
            keys    = ["first_name", "last_name", "user_id", "photo"]
            get :index, format: :json
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
            hsh = ary.first
            compare_keys(hsh, keys)
        end

        it "should return list of active users if :find is empty string" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            search_string = ""
            amount  = User.where(active: true).where('first_name ilike ?',"%#{search_string}%").count
            get :index, format: :json, find: search_string
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
        end

        it "should return users whose first_name matches a :find string" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            search_string = "n"
            amount  = User.where(active: true).where('first_name ilike ?',"%#{search_string}%").count
            get :index, format: :json, find: search_string
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
        end

        it "should return users whose first_name matches a :find string even in middle of first_name" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            search_string = "bie"
            amount  = User.where(active: true).where('first_name ilike ?',"%#{search_string}%").count
            get :index, format: :json, find: search_string
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
        end

        it "should NOT return users whose first_name doesnt match a :find string" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            search_string = "z"
            amount  = User.where(active: true).where('first_name ilike ?',"%#{search_string}%").count
            get :index, format: :json, find: search_string
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == 0
        end

        it "should return users whose last_name matches a :find string" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            search_string = "b"

            amount  = User.where(active: true).where('last_name ilike ?',"%#{search_string}%").count
            get :index, format: :json, find: search_string
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
        end

        it "should NOT return users whose last_name doesnt match a :find string" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            search_string = "z"
            amount  = User.where(active: true).where('last_name ilike ?',"%#{search_string}%").count
            get :index, format: :json, find: search_string
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == 0
        end

        it "should NOT return users whose last_name does match a :find string but they are deactivated" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            search_string = "b"

            users  = User.where('last_name ilike ?',"%#{search_string}%")
            users.each {|u| u.update(active: false) unless u == @user}

            get :index, format: :json, find: search_string
            rrc(200)
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == 1
        end
    end

    describe :show do
        it_should_behave_like("token authenticated", :get, :show, id: 1)

        before(:each) do
            @other = FactoryGirl.create(:user, first_name: "Oldie", last_name: "Quickins", email: "OTher@other.com", phone: "6567478484")
        end

        it "should return the token user if url id = 'me'" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            keys    = ["first_name", "last_name", "birthday", "email", "sex", "zip", "phone", "facebook_id", "twitter", "photo", "user_id"]
            get :show, format: :json, id: 'me'
            rrc 200
            compare_keys json["data"], keys
            json["data"]["first_name"].should == @user.first_name
            json["data"]["last_name"].should  == @user.last_name
        end

        it "should return user profile if ID does match token" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            keys    = ["first_name", "last_name", "birthday", "email", "sex", "zip", "phone", "facebook_id", "twitter", "photo", "user_id"]
            get :show, format: :json, id: @user.id
            rrc 200
            compare_keys json["data"], keys
        end

        it "should return other user profile if ID does not match token" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            keys    = ["first_name", "last_name", "user_id", "sex", "photo", "city", "zip", "state"]
            get :show, format: :json, id: @other.id
            rrc 200
            compare_keys json["data"], keys
        end

        it "should return 404 if ID does not match a record in DB" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :show, format: :json, id: (@other.id + 400)
            rrc(404)
        end

        it "should return nested user socials" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            @user.email = "new_email@gmail.com"
            @user.phone = "7568459384"
            @user.facebook_id = "1111111111"
            @user.twitter = "342342342"
            @user.save
            get :show, format: :json, id: @user.id
            rrc 200
            puts json["data"]
            json["data"]["email"].count.should == 2
            json["data"]["phone"].count.should == 2
            json["data"]["facebook_id"].count.should == 2
            json["data"]["twitter"].count.should == 2
        end
    end

    describe :profile do
        it_should_behave_like("token authenticated", :get, :profile)

        it "should return user profile for token" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            keys    = ["first_name", "last_name", "birthday", "email", "sex", "zip", "phone", "facebook_id", "twitter", "photo", "user_id"]
            get :profile, format: :json
            rrc 200
            compare_keys json["data"], keys
        end

        it "should return nested user socials" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            @user.email = "new_email@gmail.com"
            @user.phone = "7568459384"
            @user.facebook_id = "1111111111"
            @user.twitter = "342342342"
            @user.save
            get :profile, format: :json
            rrc 200
            puts json["data"]
            json["data"]["email"].count.should == 2
            json["data"]["phone"].count.should == 2
            json["data"]["facebook_id"].count.should == 2
            json["data"]["twitter"].count.should == 2
        end

        it "should include user_social_ids with phone, email, facebook_id, twitter" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :profile, format: :json
            rrc 200
            json["data"]["email"].first.class.should == Hash
            json["data"]["phone"].first.class.should == Hash
            json["data"]["facebook_id"].first.class.should == Hash
            json["data"]["twitter"].first.class.should == Hash
            json_str = json["data"]
            examples = [json_str["email"].first]
            examples << json_str["phone"].first
            examples << json_str["facebook_id"].first
            examples << json_str["twitter"].first
            examples.each do |ex|
                ex["_id"].should_not be_nil
                ex["_id"].class.should == Fixnum
                ex["value"].should_not be_nil
                ex["value"].class.should == String
            end
        end
    end

    describe :create do

        it_should_behave_like("token authenticated", :post, :create)

        context "external service tests" do

            it "should hit mailchimp endpoint with correct email for subscription" do
                ResqueSpec.reset!

                RegisterPushJob.stub(:perform).and_return(true)
                MailerJob.stub(:call_mandrill).and_return(true)
                User.any_instance.stub(:init_confirm_email).and_return(true)

                MailchimpList.any_instance.should_receive(:subscribe).and_return({"email" => "neil@gmail.com" })

                request.env["HTTP_TKN"] = GENERAL_TOKEN
                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                post :create, format: :json, data: user_hsh
                run_delayed_jobs

                user = UserSocial.find_by(identifier: "neil@gmail.com")
                user.subscribed.should be_true
            end

            it "should hit mandrill endpoint with correct email for confirm email w/o pn_token" do

                User.any_instance.stub(:persist_social_data).and_return(true)
                RegisterPushJob.stub(:perform).and_return(true)
                SubscriptionJob.stub(:perform).and_return(true)
                MailerJob.should_receive(:request_mandrill_with_template).twice
                Mandrill::API.stub(:new) { Mandrill::API }
                #Mandrill::API.should_receive(:send_template).with("iom-confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"#{NO_REPLY_EMAIL}", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"#{INFO_EMAIL}", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})
                Mandrill::API.any_instance.stub(:messages).with("iom-confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"#{NO_REPLY_EMAIL}", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"#{INFO_EMAIL}", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})

                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                request.env["HTTP_TKN"] = GENERAL_TOKEN
                post :create, format: :json, data: user_hsh
                run_delayed_jobs
            end


            it "should hit mandrill endpoint with correct email for confirm email w/ pn_token" do
                Urbanairship.stub(:register_device).and_return("pn_token", { :alias => "ua_alias"})
                User.any_instance.stub(:persist_social_data).and_return(true)
                SubscriptionJob.stub(:perform).and_return(true)
                RegisterPushJob.stub(:perform).and_return(true)
                MailerJob.should_receive(:request_mandrill_with_template).twice
                Mandrill::API.stub(:new) { Mandrill::API }
                #Mandrill::API.should_receive(:send_template).with("iom-confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"#{NO_REPLY_EMAIL}", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"#{INFO_EMAIL}", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})
                Mandrill::API.any_instance.stub(:messages).with("iom-confirm-email", [{"name"=>"recipient_name", "content"=>"Neil"}, {"name"=>"service_name", "content"=>"ItsOnMe"}], {"subject"=>"Confirm Your Email", "from_name"=>"#{SERVICE_NAME}", "from_email"=>"#{NO_REPLY_EMAIL}", "to"=>[{"email"=>"neil@gmail.com", "name"=>"Neil"}, {"email"=>"#{INFO_EMAIL}", "name"=>""}], "bcc_address"=>nil, "merge_vars"=>[{"rcpt"=>"neil@gmail.com", "vars"=>anything}]})
                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                request.env["HTTP_TKN"] = GENERAL_TOKEN
                post :create, format: :json, data: user_hsh, pn_token: "FAKE_PN_TOKENFAKE_PN_TOKEN"
                run_delayed_jobs
            end

            it "should hit urban airship endpoint with correct token and alias" do
                ResqueSpec.reset!
                PnToken.any_instance.stub(:ua_alias).and_return("fake_ua")
                User.any_instance.stub(:pn_token).and_return("FAKE_PN_TOKENFAKE_PN_TOKEN")
                SubscriptionJob.stub(:perform).and_return(true)
                MailerJob.stub(:call_mandrill).and_return(true)
                pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
                ua_alias = "fake_ua"

                Urbanairship.should_receive(:register_device).with(pn_token, { :alias => ua_alias, :provider => :ios })
                user_hsh = { "email" => "neil@gmail.com" , password: "password" , password_confirmation: "password", first_name: "Neil"}
                request.env["HTTP_TKN"] = GENERAL_TOKEN
                post :create, format: :json, data: user_hsh, pn_token: pn_token
                run_delayed_jobs # ResqueSpec.perform_all(:push)
            end
        end

        it "should create user with required fields" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            email    = "neil@gmail.com"
            user_hsh = { "email" =>  email, password: "password" , password_confirmation: "password", first_name: "Neil"}

            post :create, format: :json, data: user_hsh
            rrc(200)
            user = User.where(email: email).first
            user.first_name.should == "Neil"
        end

        it "should create user with optional pn_token and save pn_token" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            email    = "neil@gmail.com"
            user_hsh = { "email" =>  email, password: "password" , password_confirmation: "password", first_name: "Neil", pn_token: "f850c136-b74d-4fd9-a727-9912841e0a1a"}
            post :create, format: :json, data: user_hsh
            PnToken.any_instance.stub(:register)
            run_delayed_jobs
            rrc(200)
            user = User.where(email: email).first
            user.first_name.should == "Neil"
            user.pn_tokens.first.pn_token.should == "f850c136-b74d-4fd9-a727-9912841e0a1a"
        end

        it "should create user with ANDROID_TOKEN" do
            request.env["HTTP_TKN"] = ANDROID_TOKEN
            email = "neil@gmail.com"
            user_hsh = { "email" =>  email, password: "password" , password_confirmation: "password", first_name: "Neil"}

            post :create, format: :json, data: user_hsh
            rrc(200)
            user = User.where(email: email).first
            user.first_name.should == "Neil"
        end

        it "should create with blank phone string BUG FIX" do
            request.env["HTTP_TKN"] = ANDROID_TOKEN
            req_hsh = {"data"=>{"first_name"=>"Drink", "last_name"=>"Board", "email"=>"cmmca71@gmail.com", "phone"=>"", "password"=>"passwordtest", "password_confirmation"=>"passwordtest", "facebook_id"=>"110005810227565", "pn_token"=>"ec938243-f0af-4238-ab1b-b1a1d3ad59cd", "platform"=>"android"}}

            post :create, format: :json, data: req_hsh["data"]
            rrc(200)
            user = User.last
            user.first_name.should == "Drink"
            user.email.should == "cmmca71@gmail.com"
            user.user_socials.count.should == 2
            #user.phone.should be_nil

        end

        it "should process optional fields" do
            optional = [ "last_name" ,"phone", "twitter", "facebook_id", "iphone_photo", "handle"]
            requests = [{"first_name"=>"Rushit",  "password"=>"hotmail007", "last_name"=>"Patel", "phone"=>"5107543267", "email"=>"rdpatel007@gmail.com",  "iphone_photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/1076106_637557363_1453430141_n.jpg", "password_confirmation"=>"hotmail007", "facebook_id"=>637557363},
            {"first_name"=>"Kathryn",  "password"=>"Emachines4", "last_name"=>"Sell", "phone"=>"9517959756", "email"=>"Caligirlkaty@gmail.com",  "iphone_photo"=>"http://graph.facebook.com/100004277051506/picture?type=large", "password_confirmation"=>"Emachines4", "facebook_id"=>"100004277051506"},
            {"first_name"=>"Alicia",  "password"=>"clippers50", "last_name"=>"Rivera", "phone"=>"7149288304", "email"=>"shashas79@yahoo.com",  "iphone_photo"=>"http://graph.facebook.com/1045433036/picture?type=large", "password_confirmation"=>"clippers50", "facebook_id"=>"1045433036"},
            {"first_name"=>"Austen",  "password"=>"Tokujiro3", "last_name"=>"Debord", "phone"=>"3607736866", "email"=>"Austen.debord@gmail.com",  "iphone_photo"=>"http://graph.facebook.com/818275441/picture?type=large", "password_confirmation"=>"Tokujiro3", "facebook_id"=>"818275441"},
            { "password"=>"princess07", "twitter"=>"119536306",  "facebook_id"=>40200220, "password_confirmation"=>"princess07", "last_name"=>"Kimenker", "email"=>"ashlik07@gmail.com", "iphone_photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/1086486_40200220_406591072_n.jpg", "phone"=>"7027547538", "first_name"=>"Ashli", "handle"=>"@LVAshli"},
            {"first_name"=>"Brianna",  "password"=>"special1", "last_name"=>"Clater", "phone"=>"6193685354", "email"=>"bclater@gmail.com",  "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"special1"},
            {"first_name"=>"Ruby",  "password"=>"isabel123", "last_name"=>"Romero", "phone"=>"7022757785", "email"=>"rubyromero.702@gmail.com",  "iphone_photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/1076738_1168689876_1696701385_n.jpg", "password_confirmation"=>"isabel123", "facebook_id"=>1168689876},
            {"first_name"=>"Emily",  "password"=>"dietcoke05", "last_name"=>"Higashi", "phone"=>"8056306555", "email"=>"Emilyhigashi@yahoo.com",  "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"dietcoke05"},
            {"first_name"=>"Chuu",  "password"=>"torokeru", "last_name"=>"Toro", "phone"=>"4158713828", "email"=>"Toro.chuu@gmail.com",  "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"torokeru"},
            {"first_name"=>"Amanda",  "password"=>"iluv220", "last_name"=>"Stein", "email"=>"Asc220@comcast.net",  "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"iluv220"},
            {"first_name"=>"Kevin",  "password"=>"kevinn", "last_name"=>"Novak", "phone"=>"7343950489", "email"=>"kevin@uber.com",  "iphone_photo"=>"http://graph.facebook.com/28700910/picture?type=large", "password_confirmation"=>"kevinn", "facebook_id"=>"28700910"}]
            requests.each do |req_hsh|
                request.env["HTTP_TKN"] = GENERAL_TOKEN
                post :create, format: :json, data: req_hsh, pn_token: "8c5c69870825e3255bc750395f9b0680b54f458e93322109853567c85d17d48b"
                rrc(200)
                json["status"].should == 1
                json_resp = JSON.parse(response.body)
                user_id = json_resp["data"]["user_id"]
                user = User.find(user_id)
                user.class.should == User
                req_hsh['email'] = req_hsh['email'].downcase
                req_hsh.each_key do |key|
                    if (key != "password") && (key != "password_confirmation")
                        user.send(key).should == req_hsh[key].to_s unless (req_hsh[key].to_s == "http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg")

                    end
                end
            end
        end

        it "should return correct keys on success" do
            email = "neil@gmail.com"
            user_hsh = { "email" =>  email, password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc(200)
            keys = ["first_name", "last_name", "birthday", "email", "zip", "phone", "facebook_id", "twitter", "photo", "user_id", "token"]
            hsh  = json["data"]
            compare_keys(hsh, keys)
            user = User.where(email: email).first
            st = user.session_tokens.last
            user.session_token_obj = st
            json["status"].should == 1
            json["data"].should   == user.create_serialize
        end

        it "should not accept missing / invalid required fields" do
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password", first_name: ""}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json['status'].should == 0
            json["data"]["error"]["first_name"].should == ["can't be blank"]
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password", first_name: nil}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"]["first_name"].should == ["can't be blank"]
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password" }
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"]["first_name"].should == ["can't be blank"]
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "passasdfword", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"password_confirmation"=>["doesn't match Password"]}
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"password_confirmation"=>["doesn't match Password", "can't be blank"]}
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: nil, first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"password_confirmation"=>["can't be blank"]}
            user_hsh = { "email" =>  "neil@gmail.com", password: "passasdfword" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"password_confirmation"=>["doesn't match Password"]}
            user_hsh = { "email" =>  "neil@gmail.com", password: "" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"password"=>["can't be blank", "is too short (minimum is 6 characters)"]}
            user_hsh = { "email" =>  "neil@gmail.com", password: nil , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"password"=>["can't be blank", "is too short (minimum is 6 characters)"]}
            user_hsh = { "email" =>  "neil@gmail.com", password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"password"=>["can't be blank", "is too short (minimum is 6 characters)"]}
            user_hsh = { "email" =>  "neimail.com", password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"email"=>["is invalid"]}
            user_hsh = { "email" =>  "", password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"email"=>["is invalid"]}
            user_hsh = { "email" =>  nil, password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"email"=>["is invalid"]}
            user_hsh = { password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json =  JSON.parse(response.body)
            json['status'].should == 0
            json["data"]["error"].should == {"email"=>["is invalid"]}
        end

        it "should not accept requests without user_hash" do
            user_hsh = { password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json
            rrc(400)
        end

        it "should not return 'password digest' validation fail" do
            user_hsh = { "email" =>  "neil@gmail.com", password: "" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json["status"].should == 0
            json["data"].has_key?("password_digest").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password: nil , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json["status"].should == 0
            json["data"].has_key?("password_digest").should be_false
            user_hsh = { "email" =>  "neil@gmail.com", password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, data: user_hsh
            rrc 200
            json["status"].should == 0
            json["data"].has_key?("password_digest").should be_false
        end

        it "should not save bad pn token but allow login" do
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            token = "9128341983439adsfasd487123"
            post :create, format: :json, data: user_hsh, pn_token: token
            keys = ["first_name", "last_name", "birthday", "email", "zip", "phone", "facebook_id", "twitter", "photo", "user_id", "token"]
            hsh  = json["data"]
            compare_keys(hsh, keys)
            user = User.where(email: "neil@gmail.com").first
            json["status"].should == 1
        end

        it "should record user's pn token" do
            user_hsh = { "email" =>  "neil@gmail.com", password: "password" , password_confirmation: "password", first_name: "Neil"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            token = "91283419asdfasdfasdfasdfasdfa83439487123"
            post :create, format: :json, data: user_hsh, pn_token: token
            PnToken.any_instance.stub(:register)
            run_delayed_jobs
            rrc(200)
            user = User.where(email: "neil@gmail.com").first
            pn_token = PnToken.where(pn_token: token).first
            pn_token.pn_token.should == token
            pn_token.class.should    == PnToken
            pn_token.user_id.should  == user.id
        end

        it "should create two with twitter if requests are immediately back to back - BUG FIX - this will be prevented on the client" do
            user_hsh = {"twitter"=>"42802561", "handle"=>"@bffmike", "first_name"=>"Mike", "phone"=>"2063512119", "password"=>"[FILTERED]", "last_name"=>"Manzano", "email"=>"leftspin@me.com", "iphone_photo"=>"http://graph.facebook.com/624902237/picture?type=large", "password_confirmation"=>"[FILTERED]", "facebook_id"=>"624902237"}
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            token = "91283419asdfasdfasdfasdfasdfa83439487123"
            post :create, format: :json, data: user_hsh, pn_token: token
            post :create, format: :json, data: user_hsh, pn_token: token
            rrc(200)
            User.where(twitter: "42802561").count.should == 1
        end

        it "it should save when a client uploads the default broken photo URL - BUG FIX" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            user_hsh = {"first_name"=>"Zoe", "phone"=>"9196368282", "password"=>"passwordtest", "last_name"=>"Gan", "email"=>"nageoz@gmail.com", "iphone_photo"=>"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg", "password_confirmation"=>"passwordtest"}
            post :create, format: :json, data: user_hsh
            rrc(200)
            user = User.where(first_name: "Zoe").first
            user.get_photo.should_not == "http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"
        end

    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update)

        it "should require a update_user hash" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: "updated data"
            rrc(400)
            put :update, format: :json, data: nil
            rrc(400)
            put :update, format: :json
            rrc(400)
        end

        it "should return user hash when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: { zip: "89475", sex: "male", birthday: "03/13/1975"}
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            response.class.should  == Hash
            keys = ["user_id", "photo", "first_name", "last_name", "phone", "email", "sex", "birthday", "zip", "twitter", "facebook_id"]
            compare_keys(response, keys)
        end

        it "should return user hash when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: {"first_name"=>"Phillip", "last_name"=>"Park", "phone"=>"(312) 408-1518", "email"=>"phillark79@gmail.com", "facebook_id"=>"1056958975"}
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            response.class.should  == Hash
            keys = ["user_id", "photo", "first_name", "last_name", "phone", "email", "sex", "birthday", "zip", "twitter", "facebook_id"]
            compare_keys(response, keys)
        end

        it "should return user hash when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: {"first_name"=>"William", "last_name"=>"Miller", "phone"=>"(703) 830-0070", "email"=>"will.llanes.migrer@gmail.com", "facebook_id"=>"100000320758243", "twitter"=>"4129d972"}
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            response.class.should  == Hash
            keys = ["user_id", "photo", "first_name", "last_name", "phone", "email", "sex", "birthday", "zip", "twitter", "facebook_id"]
            compare_keys(response, keys)
        end

        it "should return validation errors" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: { "email" => "" }
            rrc 200
            json["status"].should == 0
            json["data"].class.should    == Hash
            json["data"]["error"]["email"].should == ["is invalid"]
        end

        it "should return duplicate user_social error when active user_socials already exist" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            other_user = FactoryGirl.create(:user, facebook_id: "keeper_other")
            put :update, format: :json, data: { "facebook_id" => "keeper_other" }
            rrc 200
            json["status"].should == 0
            json["data"].class.should    == Hash
            json["data"]["error"]["facebook_id"].should == ["is already in use. Please email support@itson.me for assistance if this is in error", "is already on an acount, please use that to log in"]
        end

        {
            first_name: "Ray",
            last_name:  "Davies",
            email: "ray@davies.com",
            phone: "5877437859",
            birthday: "10/10/1971",
            sex: "female",
            zip: "85733",
            phone: "(702) 410-9605",
            twitter: "65787323",
            facebook_id: "98136459814"
        }.stringify_keys.each do |type_of, value|

            it "should update the user #{type_of} in database for non-socials" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                put :update, format: :json, data: { type_of => value }
                new_user = @user.reload
                value = "7024109605" if value == "(702) 410-9605"
                unless ["email", "phone", "twitter", "facebook_id"].include?(type_of)
                    new_user.send(type_of).should == value
                end
            end

            it "should update the user #{type_of} in database for user-socials" do
                request.env["HTTP_TKN"] = "USER_TOKEN"
                put :update, format: :json, data: { type_of => value }
                new_user = @user.reload
                value = "7024109605" if value == "(702) 410-9605"
                if ["email", "phone", "twitter", "facebook_id"].include?(type_of)
                    new_user.send(type_of).should == value
                end
            end
        end

        it "should not update attributes that dont exist and fail" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            hsh = { "house" => "chill" }
            put :update, format: :json, data: hsh
            rrc(400)
        end

        it "should not update attributes that are not allowed and fail" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            hsh = { "password" => "doNOTallow", "remember_token" => "DO_NOT_ALLOW" }
            put :update, format: :json, data: hsh
            rrc(400)
        end

        it "should return the correct error message for bad email" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            hsh = { "email" => "aslkd;fj" }
            put :update, format: :json, data: hsh
            rrc(200)
            json["status"].should == 0
            json["data"].class.should    == Hash
            json["data"]["error"]["email"].should == ["is invalid"]
        end

        it "should return the correct error message for bad phone" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            hsh = { "phone" => "39827" }
            put :update, format: :json, data: hsh
            rrc(200)
            json["status"].should == 0
            json["data"].class.should    == Hash
            json["data"]["error"]["phone"].should == ["is invalid"]
        end

        it "should be able to handle fb id sent as integer" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            hsh = { "facebook_id" => 39827 }
            put :update, format: :json, data: hsh
            rrc(200)
            json["status"].should == 1
            json["data"]["facebook_id"].should == "39827"
        end
    end

    describe :socials do
        it_should_behave_like("token authenticated", :put, :socials)

        it "should require a update_user hash" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :socials, format: :json, data: "updated data"
            rrc(400)
            put :socials, format: :json, data: nil
            rrc(400)
            put :socials, format: :json
            rrc(400)
        end

        it "should return user hash when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :socials, format: :json, data: { zip: "89475", sex: "male", birthday: "03/13/1975"}
            rrc(200)
            json["status"].should == 1
            response = json["data"]
            response.class.should  == Hash
            keys = ["user_id", "photo", "first_name", "last_name", "phone", "email", "sex", "birthday", "zip", "twitter", "facebook_id"]
            compare_keys(response, keys)
        end

        it "should update user socials via id" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :socials, format: :json, data: { zip: "89475", sex: "male", birthday: "03/13/1975"}
            rrc(200)
        end

        it "should return profile_with_ids" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :socials, format: :json, data: { zip: "89475", sex: "male", birthday: "03/13/1975"}
            rrc(200)
            json["data"].should == @user.reload.profile_with_ids_serialize
        end

        xit "should return profile_with_ids + error validations when some updates fail" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :socials, format: :json, data: { zip: "89475", sex: "male", birthday: "03/13/2115"}
            rrc(200)
            json["data"].should  == @user.reload.profile_with_ids_serialize
            json["error"].should == [{ "sex" => "Please retry"}, { "birthday" => "Birthdate cannot be in the future"}]
        end

        it "should iterate thru entire put hash and update user record and user_social records" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            @user.update(email: "new_social@gmail.com", phone: "6469876543")
            social2  = UserSocial.where(type_of: "email", identifier: "new_social@gmail.com").first
            social1  = UserSocial.where(type_of: "phone", identifier: "6469876543").first

            hsh = { "first_name" => "Newfirstname", "last_name" => "Newlastname", "birthday" => "3/12/89", "zip" => "15364", "sex" => "male", "social" => [ { "_id" => social1.id, "value" => "2154647839"}, { "_id" => social2.id, "value" => "new@gmail.com"} ] }
            put :socials, format: :json, data: hsh
            json["status"].should == 1
            json["data"].should   ==  @user.reload.profile_with_ids_serialize
            # test that the user socials are updated
            us1 = UserSocial.find(social2.id)
            us1.identifier.should == "new@gmail.com"
            us1.type_of.should    == 'email'
            us2 = UserSocial.find(social1.id)
            us2.identifier.should == "2154647839"
            us2.type_of.should    == 'phone'
        end

        it "should iterate thru entire put hash and update user record but NO user_social records" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            @user.update(email: "new_social@gmail.com", phone: "6469876543")
            social1  = UserSocial.where(type_of: "email", identifier: "new_social@gmail.com").first
            social2  = UserSocial.where(type_of: "phone", identifier: "6469876543").first

            hsh = { "first_name" => "Newfirstname", "last_name" => "Newlastname", "birthday" => "3/12/89", "zip" => "15364", "sex" => "male" }
            put :socials, format: :json, data: hsh
            json["status"].should == 1
            json["data"].should   == @user.reload.profile_with_ids_serialize
        end

        it "should not update attributes that dont exist and fail" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            hsh = { "house" => "chill" }
            put :socials, format: :json, data: hsh
            rrc(400)
        end

        it "should not update attributes that are not allowed and fail" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            hsh = { "password" => "doNOTallow", "remember_token" => "DO_NOT_ALLOW" }
            put :socials, format: :json, data: hsh
            rrc(400)
        end

    end

    describe :deactivate_user_social do

        it "should return 400 if last email" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :deactivate_user_social, format: :json, identifier: @user.email, type: "email"
            rrc(200)
        end

        it_should_behave_like("token authenticated", :put, :deactivate_user_social)

        it "should return user ID on success" do
            FactoryGirl.create :user_social, user_id: @user.id, type_of: "email", identifier: "secondemail@email.com"
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :deactivate_user_social, format: :json, identifier: @user.email, type: "email"
            rrc(200)
            json["status"].should == 1
            json["data"].should   == @user.id
            put :deactivate_user_social, format: :json, identifier: @user.phone, type: "phone"
            rrc(200)
            json["status"].should == 1
            json["data"].should   == @user.id
            put :deactivate_user_social, format: :json, identifier: @user.facebook_id, type: "facebook_id"
            rrc(200)
            json["status"].should == 1
            json["data"].should   == @user.id
            put :deactivate_user_social, format: :json, identifier: @user.twitter, type: "twitter"
            rrc(200)
            json["status"].should == 1
            json["data"].should   == @user.id
        end

        it "should deActivate the user social in the database" do
            FactoryGirl.create :user_social, user_id: @user.id, type_of: "email", identifier: "secondemail@email.com"
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :deactivate_user_social, format: :json, identifier: @user.email, type: "email"
            rrc(200)
            UserSocial.unscoped.where(identifier: @user.email).first.active.should be_false
            put :deactivate_user_social, format: :json, identifier: @user.phone, type: "phone"
            rrc(200)
            UserSocial.unscoped.where(identifier: @user.phone).first.active.should be_false
            put :deactivate_user_social, format: :json, identifier: @user.facebook_id, type: "facebook_id"
            rrc(200)
            UserSocial.unscoped.where(identifier: @user.facebook_id).first.active.should be_false
            put :deactivate_user_social, format: :json, identifier: @user.twitter, type: "twitter"
            rrc(200)
            UserSocial.unscoped.where(identifier: @user.twitter).first.active.should be_false
        end

        it "should return 404 with no ID or wrong ID" do
            FactoryGirl.create :user_social, user_id: @user.id, type_of: "email", identifier: "secondemail@email.com"
            request.env["HTTP_TKN"] = "USER_TOKEN"
            user2 = FactoryGirl.create(:user, email: "notthis@no.com", phone: "9879887878")
            put :deactivate_user_social, format: :json, identifier: user2.email, type: "email"
            rrc(404)
            put :deactivate_user_social, format: :json, identifier: user2.phone, type: "phone"
            rrc(404)
        end
    end

    describe :reset_passord do
        it_should_behave_like("token authenticated", :put, :reset_password)

        before do
            @receiver = FactoryGirl.create(:receiver, email: "findme@gmail.com")
            ResqueSpec.reset!
        end

        it "should accept Android Token" do
            request.env["HTTP_TKN"] = ANDROID_TOKEN
            put :reset_password, format: :json, data: @receiver.email
            rrc(200)
            json["status"].should  == 1
            json["data"].should == "Email is Sent , check your inbox"
        end

        it "should send success response for screen for primary email" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            put :reset_password, format: :json, data: @receiver.email
            rrc(200)
            json["status"].should  == 1
            json["data"].should == "Email is Sent , check your inbox"
        end

        it "should update the user reset password token and expiration for primary email" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            put :reset_password, format: :json, data: @receiver.email
            rrc(200)
            @receiver.reload
            @receiver.reset_token.should_not be_nil
            @receiver.reset_token_sent_at.utc.hour.should == Time.now.utc.hour
        end

        it "should send success response for screen for secondary email" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @receiver.email = "new_email@email.com"
            @receiver.save
            put :reset_password, format: :json, data: "findme@gmail.com"
            rrc(200)
            json["status"].should  == 1
            json["data"].should == "Email is Sent , check your inbox"
        end

        it "should update the user reset password token and expiration for secondary email" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @receiver.email = "new_email@email.com"
            @receiver.save
            put :reset_password, format: :json, data: "findme@gmail.com"
            rrc(200)
            @receiver.reload
            @receiver.reset_token.should_not be_nil
            @receiver.reset_token_sent_at.utc.hour.should == Time.now.utc.hour
        end

        it "should return error message if email doesn not exist" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            put :reset_password, format: :json, data: "non-existant@yahoo.com"
            rrc(404)
            json["status"].should  == 0
            json["data"].should == "#{PAGE_NAME} does not have record of that email"
        end

        it "should only accept email string" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            put :reset_password, format: :json, data: ["non-existant@yahoo.com"]
            rrc(400)
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            put :reset_password, format: :json, data: { "email" => "non-existant@yahoo.com"}
            rrc(400)
        end

        it "should send the reset password email" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            put :reset_password, format: :json, data: @receiver.email
            rrc(200)
            json["status"].should  == 1
            json["data"].should == "Email is Sent , check your inbox"

            run_delayed_jobs
            email_link = "#{PUBLIC_URL}/account/resetpassword/#{@receiver.reset_token}"
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-reset-password"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/#{email_link}/)
                else
                    true
                end

            }.once
        end
    end

end

