require 'spec_helper'

describe UserSocial do

    # require a user_id, type, identifier
    # accepts email , phone , facebook_id, twitter_id

    it "builds from factory" do
      user_social = FactoryGirl.create :user_social
      user_social.should be_valid
    end


end