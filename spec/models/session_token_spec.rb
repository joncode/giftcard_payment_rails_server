require 'spec_helper'

describe SessionToken do

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


end
