require 'spec_helper'

describe SessionToken do

	it 'builds from factory' do
        st = FactoryGirl.create :session_token
        st.should be_valid
    end

	it "should associate with user" do
		u              = FactoryGirl.create(:user)
		st             = SessionToken.find_or_create_by(user_id: u.id, token: u.remember_token)
		st.user.should == u
    end

    it "should authenticate a request with token alone and return a user" do
		u                             = FactoryGirl.create(:user)
		st                            = SessionToken.find_or_create_by(user_id: u.id, token: u.remember_token)
		user                          = SessionToken.app_authenticate(u.remember_token)
		user.class.should             == User
		user.id.should                == u.id
		user.session_token_obj.should == st
    end

    it "requires a token" do
		u              = FactoryGirl.create(:user)
		st             = SessionToken.find_or_create_by(user_id: u.id, token: nil)
      	st.should_not be_valid
      	st.should have_at_least(1).error_on(:token)
    end

    it "should create a token object" do
    	user                  = FactoryGirl.create(:user)
    	platform = 'android'
    	pn_token = '72938472938472938472938472398472397492384'
		sto                   = SessionToken.create_token_obj(user, platform, pn_token)
		stodb                 = SessionToken.last
		sto.should            == stodb
		stodb.user_id.should  == user.id
		stodb.platform.should == platform
		stodb.push.should     == pn_token
		stodb.token.should_not be_nil
    end

    it "should spin of a resque to save the pn_token" do
    	platform = 'android'
    	pn_token = '72938472938472938472938472398472397492384'
    	user = FactoryGirl.create(:user)
    	ResqueSpec.reset!
    	PnToken.any_instance.stub(:register)
    	User.any_instance.should_receive(:pn_token=).with(["72938472938472938472938472398472397492384", "android"])
    	SessionToken.create_token_obj(user, platform, pn_token)
		run_delayed_jobs
    end


end
# == Schema Information
#
# Table name: session_tokens
#
#  id         :integer         not null, primary key
#  token      :string(255)
#  user_id    :integer
#  device_id  :integer
#  platform   :string(255)
#  push       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

