require 'spec_helper'

include UserSessionFactory
include AffiliateFactory

describe Web::V3::UsersController do

    describe "create" do

    	before(:each) do
            User.delete_all
            @client = make_partner_client('Client', 'Tester')
            request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
            request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
    	end

        it_should_behave_like("client-token authenticated", :post, :create)

        it "should create user" do
            request_hsh = {
            	first_name: "abe",
            	last_name: "anderson",
            	email: "abe@email.com",
            	password: "password",
            	password_confirmation: "password"
            }
            post :create, format: :json, data: request_hsh
            rrc(200)
            u = User.last

            u.client.should == @client
            u.partner.should == @client.partner

            @client.contents(:users).first.should == u

            json["status"].should == 1
            json["data"]["email"][0].should == { "_id" => UserSocial.last.id, "value" => "abe@email.com" }
        end

        it "should create user and associate with an affiliate if link is given" do
            a1 = make_affiliate("Afff", "One")
            a1.total_users.should == 0
            lp = FactoryGirl.create(:landing_page, link: "itson.me/san-diego?aid=twister_ice_tea", clicks: 2, affiliate_id: a1.id)
            request_hsh = {"first_name" => "First", "email" => "aff@user.com", "password" => "passpass", "password_confirmation"=> "passpass", "last_name" => "archangle", "link" => "itson.me/san-diego?aid=twister_ice_tea" }
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 1
            a1.reload
            a1.total_users.should == 1
            a1.users.count.should == 1
            lp.reload.users.should == 1
            u = a1.users.first
            a1.users.first.should == u
            u.affiliation.name.should == "First Archangle"
        end

        it "should fail silently is link is not good" do
            a1 = make_affiliate("Afff", "One")
            a1.total_users.should == 0
            lp = FactoryGirl.create(:landing_page, link: "itson.me/san-diego?aid=twister_ice_tea", clicks: 2, affiliate_id: a1.id)
            request_hsh = {"first_name" => "First", "email" => "aff@user.com", "password" => "passpass", "password_confirmation"=> "passpass", "last_name" => "archangle", "link" => "itson.me/san-diego?aitwister_ice_tea" }
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 1
            a1.reload
            a1.total_users.should == 0
            a1.users.count.should == 0
            lp.reload.users.should == 0
        end

        it "should return correct error" do
            request_hsh = {
            	first_name: "abe",
            	last_name: "anderson",
            	email: "abe@email.com",
            	password: "password",
            	password_confirmation: "wrong"
            }
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 0
            json["err"].should    == "INVALID_INPUT"
            json["msg"].should    == "User could not be created"
            json["data"].should   == [{ "name" => "password confirmation", "msg" => "doesn't match Password" }]
        end

    end

    describe "update" do

        before(:each) do
            @client = make_partner_client('Client', 'Tester')
            @user = create_user_with_token "USER_TOKEN", nil, @client
            request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
        end

        it_should_behave_like("client-token authenticated", :patch, :update)

        it "should persist the data to the user record" do
            user = @user
            request_hsh = {
                last_name: "anderson"
            }
            patch :update, format: :json, data: request_hsh

            user.reload
            user.last_name.should == "Anderson"
        end

        it "should return an error when parsing a bad date" do
            user = @user
            request_hsh = { "first_name"=>"William", "last_name"=>"King", "birthday"=>"131156", "zip"=>"89014"}
            patch :update, format: :json, data: request_hsh

            rrc(200)
            json["status"].should == 0
        end

        it "should return a full json object of the user" do
            user = @user
            request_hsh = {
                last_name: "anderson"
            }
            patch :update, format: :json, data: request_hsh
            user.reload
            rrc(200)
            json["status"].should == 1
            json["data"].should == user.login_web_serialize
        end

        it "should update the individual user socials by id" do
            user = @user
            user.update(phone: "4325654895")
            user_social = UserSocial.where(identifier: "4325654895").first
            request_hsh = {
                social: [{ "_id" => user_social.id, "value" => "545-575-6879" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            user_social.reload
            user_social.identifier.should == "5455756879"
        end

        it "should create the individual user socials by id" do
            user = @user
            user.update(phone: "4325654895")
            user_social = UserSocial.where(identifier: "4325654895").first
            request_hsh = {
                social: [{ "net" => 'ph', "value" => "545-575-6879" }, { "_id" => user_social.id, "value" => "(432) 677-8999" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            user_social.reload
            user_social.identifier.should  == "4326778999"
            nuser_social                   = UserSocial.where(identifier: "5455756879").first
            nuser_social.identifier.should == "5455756879"
            nuser_social.type_of.should    == "phone"
        end

        it "should return email validation errors and not update anything" do
            user = @user
            user.update(email: "good@rmail.net")
            user_social = UserSocial.where(identifier: "good@rmail.net").first
            request_hsh = {
                last_name: "new_last_name",
                social: [{ "_id" => user_social.id, "value" => "newbieramil.net" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 0
            json["err"].should == "INVALID_INPUT"
            json["msg"].should == "User could not be created"
            json["data"].should == [{"name"=>"email", "msg"=>"email is invalid"}]
            user.reload
            user.last_name.should_not == "new_last_name"
            user_social.reload
            user_social.identifier.should == "good@rmail.net"
        end

        it "should allow updates to photo_url" do
            user = @user
            request_hsh = {
                photo: "http://res.cloudinary.com/drinkboard/upload/version/92364029/hnkjfasdoiyfliaeh.jpg"
            }
            patch :update, format: :json, data: request_hsh

            user.reload
            user.get_photo.should == "http://res.cloudinary.com/drinkboard/upload/version/92364029/hnkjfasdoiyfliaeh.jpg"
        end

        it "should return phone validation errors and not update anything" do
            user = @user
            user.update(phone: "4325654895")
            user_social = UserSocial.where(identifier: "4325654895").first
            request_hsh = {
                last_name: "new_last_name",
                social: [{ "_id" => user_social.id, "value" => "465-238-942" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 0
            json["err"].should == "INVALID_INPUT"
            json["msg"].should == "User could not be created"
            json["data"].should == [{"name"=>"phone", "msg"=>"phone number is invalid"}]
            user.reload
            user.last_name.should_not == "new_last_name"
            user_social.reload
            user_social.identifier.should == "4325654895"
        end

        it "should accept the photo key BUG FIX" do
            user = @user
            user.update(phone: "4325654895")
            us = FactoryGirl.create(:user_social, user_id: user.id, type_of: "email", identifier: "roger1@rogerson.com")
            request_hsh =  {"social"=>[{"_id"=>us.id, "value"=>"roger@rogerson.com"}, {"net"=>"ph", "value"=>"(702) 927-2102"}], "first_name"=>"Roger", "last_name"=>"Rogerson", "birthday"=>nil, "zip"=>nil, "sex"=>nil, "photo"=>nil}
            patch :update, format: :json, data: request_hsh
            rrc(200)
            us.reload.identifier.should == "roger@rogerson.com"
        end
    end

    describe "reset_passord" do

        before(:each) do
            User.delete_all
            @client = make_partner_client('Client', 'Tester')
            request.env['HTTP_X_APPLICATION_KEY'] = @client.application_key
            request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
            @receiver = FactoryGirl.create(:receiver, email: "findme@gmail.com")
            ResqueSpec.reset!
        end

        it_should_behave_like("client-token authenticated", :patch, :reset_password)

        it "should accept Android Token" do
            request.env["HTTP_TKN"] = ANDROID_TOKEN
            patch :reset_password, format: :json, data: @receiver.email
            rrc(200)
            json["status"].should  == 1
            json["data"].should == "Email is Sent , check your inbox"
        end

        it "should send success response for screen for primary email" do
            patch :reset_password, format: :json, data: @receiver.email
            rrc(200)
            json["status"].should  == 1
            json["data"].should == "Email is Sent , check your inbox"
        end

        it "should update the user reset password token and expiration for primary email" do
            patch :reset_password, format: :json, data: @receiver.email
            rrc(200)
            @receiver.reload
            @receiver.reset_token.should_not be_nil
            @receiver.reset_token_sent_at.utc.hour.should == Time.now.utc.hour
        end

        it "should send success response for screen for secondary email" do
            @receiver.email = "new_email@email.com"
            @receiver.save
            patch :reset_password, format: :json, data: "findme@gmail.com"
            rrc(200)
            json["status"].should  == 1
            json["data"].should == "Email is Sent , check your inbox"
        end

        it "should update the user reset password token and expiration for secondary email" do
            @receiver.email = "new_email@email.com"
            @receiver.save
            patch :reset_password, format: :json, data: "findme@gmail.com"
            rrc(200)
            @receiver.reload
            @receiver.reset_token.should_not be_nil
            @receiver.reset_token_sent_at.utc.hour.should == Time.now.utc.hour
        end

        it "should return error message if email doesn not exist" do
            patch :reset_password, format: :json, data: "non-existant@yahoo.com"
            rrc(404)
            json["status"].should  == 0
            json["data"].should == "#{PAGE_NAME} does not have record of that email"
        end

        it "should only accept email string" do
            patch :reset_password, format: :json, data: ["non-existant@yahoo.com"]
            rrc(400)
            patch :reset_password, format: :json, data: { "email" => "non-existant@yahoo.com"}
            rrc(400)
        end

        it "should send the reset password email" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            patch :reset_password, format: :json, data: @receiver.email
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
