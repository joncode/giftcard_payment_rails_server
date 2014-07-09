require 'spec_helper'

describe Ditto do

	it "builds from factory" do
		ditto = FactoryGirl.build :ditto
		ditto.should be_valid
		ditto.save
	end

	context "associations" do

		it "should associate with user" do
			user  = FactoryGirl.create(:user)
			ditto = FactoryGirl.create :ditto, notable_id: user.id, notable_type: user.class.to_s
			ditto.notable.should == user
		end

		it "should associate with user_social" do
			user_social = FactoryGirl.create(:user_social)
			ditto       = FactoryGirl.create :ditto, notable_id: user_social.id, notable_type: user_social.class.to_s
			ditto.notable.should == user_social
		end

		it "should associate with gift" do
			gift  = FactoryGirl.create(:gift)
			ditto = FactoryGirl.create :ditto, notable_id: gift.id, notable_type: gift.class.to_s
			ditto.notable.should == gift
		end

	end

	context "Behavoir" do

		it "should have response not as JSON" do
			user  = FactoryGirl.create(:user)
			ditto = FactoryGirl.create :ditto, notable_id: user.id, notable_type: user.class.to_s
			ditto.response.class.should_not == String
		end
	end

	context "Class Methods" do

		before(:each) do
			@user = FactoryGirl.create(:user)
		end

		describe :subscription_email_create do

			it "should create with success" do
				user_social = FactoryGirl.create(:user_social, user_id: @user.id)
				resp = {"email"=>"cgamboa@gmail.com", "euid"=>"931908a11a", "leid"=>"117276957"}
				d    = Ditto.subscription_email_create(resp, user_social.id)
				d.response_json.should == resp.to_json
				d.status.should        == 200
				d.cat.should           == 400
				d.notable_id.should    == user_social.id
				d.notable_type.should  == "UserSocial"
			end

			it "should create with not modified when already on" do
				user_social = FactoryGirl.create(:user_social, user_id: @user.id)
				resp = "cgamboa@gmail.com is already subscribed to the list"
				d    = Ditto.subscription_email_create(resp, user_social.id)
				d.response_json.should == resp.to_json
				d.status.should        == 304
				d.cat.should           == 400
				d.notable_id.should    == user_social.id
				d.notable_type.should  == "UserSocial"
			end

			it "should create with list not found" do
				user_social = FactoryGirl.create(:user_social, user_id: @user.id)
				resp = "The list could not be found"
				d    = Ditto.subscription_email_create(resp, user_social.id)
				d.response_json.should == resp.to_json
				d.status.should        == 404
				d.cat.should           == 400
				d.notable_id.should    == user_social.id
				d.notable_type.should  == "UserSocial"
			end
		end

		describe :send_email_create do

			it "should create with success" do
				resp = [{"email"=>"circa@cox.net", "status"=>"sent", "_id"=>"94ffed45365d4bf4bd573687db64ade8", "reject_reason"=>nil}, {"email"=>"info@itson.me", "status"=>"sent", "_id"=>"6fce863f7ee04e7db74b019b2c326efb", "reject_reason"=>nil}]
				d    = Ditto.send_email_create(resp, @user.id, "User")
				d.response_json.should == resp.to_json
				d.status.should        == 200
				d.cat.should           == 310
				d.notable_id.should    == @user.id
				d.notable_type.should  == "User"
			end

		end

		describe :register_push_create do

			it "should create with error" do
				resp = {"error_code"=>40001, "details"=>{"device_token"=>["device_token contains an invalid device token: A7D14290-FD57-41F0-B1A4-DB36F6E9B79B"]}, "error"=>"Data validation error"}
				d    = Ditto.register_push_create(resp, @user.id)
				d.response_json.should == resp.to_json
				d.status.should        == 422
				d.cat.should           == 100
				d.notable_id.should    == @user.id
				d.notable_type.should  == "User"
			end

		end

		describe :send_push_create do

			it "should create with success" do
				gift = FactoryGirl.create(:gift, receiver: @user)
				resp = {"push_id"=>"f8fb691e-0543-11e4-9d68-90e2ba025308"}
				d    = Ditto.send_push_create(resp, gift.id)
				d.response_json.should == resp.to_json
				d.status.should        == 200
				d.cat.should           == 110
				d.notable_id.should    == gift.id
				d.notable_type.should  == "Gift"
			end
		end
	end


end
