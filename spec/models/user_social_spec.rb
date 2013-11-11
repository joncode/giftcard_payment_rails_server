require 'spec_helper'

describe UserSocial do

    # require a user_id, type_of, identifier
    # accepts email , phone , facebook_id, twitter_id

    it "builds from factory" do
      user_social = FactoryGirl.create :user_social
      user_social.should be_valid
    end

    it "requires identifier" do
      user_social = FactoryGirl.build(:user_social, :identifier => nil)
      user_social.should_not be_valid
      user_social.should have_at_least(1).error_on(:identifier)
    end

    it "requires user_id" do
      user_social = FactoryGirl.build(:user_social, :user_id => nil)
      user_social.should_not be_valid
      user_social.should have_at_least(1).error_on(:user_id)
    end

    it "requires type_of" do
      user_social = FactoryGirl.build(:user_social, :type_of => nil)
      user_social.should_not be_valid
      user_social.should have_at_least(1).error_on(:type_of)
    end

    it "should update user_social.subscribed if subscribe is successful" do
      Resque.should_receive(:enqueue).with(SubscriptionJob, anything)
      user_social = FactoryGirl.create(:user_social, type_of: "email", identifier:"test@email.com")
    end

end

# == Schema Information
#
# Table name: user_socials
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  type_of    :string(255)
#  identifier :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  active     :boolean         default(TRUE)
#

