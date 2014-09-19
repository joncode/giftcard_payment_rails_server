require 'spec_helper'

describe UserSocial do

    it "should accept twitter from app" do
        user = FactoryGirl.create(:user, twitter: "123121231")
        old_us = UserSocial.where(identifier: "294473465").first
        old_us.destroy if old_us
        us = UserSocial.create(type_of: "twitter", identifier: "284473465", user_id: user.id)
        #user.user_socials << us
        us.should be_valid
    end

    it "builds from factory" do
      user_social = FactoryGirl.build :user_social
      user_social.should be_valid
    end

    it "requires identifier" do
      user_social = FactoryGirl.build(:user_social, :identifier => nil)
      user_social.should_not be_valid
      user_social.should have_at_least(1).error_on(:identifier)
    end

    it "requires type_of" do
      user_social = FactoryGirl.build(:user_social, :type_of => nil)
      user_social.should_not be_valid
      user_social.should have_at_least(1).error_on(:type_of)
    end

    it "requires user_id" do
      user_social = FactoryGirl.build(:user_social, :user_id => nil)
      user_social.should_not be_valid
      user_social.should have_at_least(1).error_on(:user_id)
    end

    it "should associate with dittos" do
        user  = FactoryGirl.create(:user_social)
        ditto = FactoryGirl.create :ditto, notable_id: user.id, notable_type: user.class.to_s
        user.dittos.first.should == ditto
    end

    it "should update user_social.subscribed if subscribe is successful" do
      Resque.should_receive(:enqueue).with(CollectIncompleteGiftsV2Job, anything)
      Resque.should_receive(:enqueue).with(SubscriptionJob, anything)
      user_social = FactoryGirl.create(:user_social, type_of: "email", identifier:"test@email.com")
    end

    it "should extract phone digits from dashed phone string" do
        UserSocial.delete_all
        user_social = FactoryGirl.build(:user_social, type_of: "phone", identifier: "222-333-4567")
        user_social.save
        user_social.identifier.should_not == "222-333-4567"
        user_social.identifier.should == "2223334567"
    end

    it "should extract phone digits from dashed spaced and parenthesis phone string" do
        UserSocial.delete_all
        user_social = FactoryGirl.build(:user_social, type_of: "phone", identifier: "(312) 404-1512")
        user_social.save
        user_social.identifier.should_not == "(312) 404-1512"
        user_social.identifier.should == "3124041512"
    end

    describe "uniqueness validation" do

        before do
            User.delete_all
            UserSocial.delete_all
            @legacy_user = FactoryGirl.create(:user, first_name: "ace", email: "ace@email.com", phone: "2222222222")
            @legacy_phone = @legacy_user.user_socials.where(type_of: "phone")[0]
            @legacy_email = @legacy_user.user_socials.where(type_of: "email")[0]
        end

        context "unique identifier" do
            it "should save and make active on" do

                new_phone = UserSocial.create(type_of: "phone", identifier: "3333333333", user_id: @legacy_user.id)
                new_phone.id.should_not be_nil
                new_phone.active.should == true
                new_email = UserSocial.create(type_of: "email", identifier: "bob@email.com", user_id: @legacy_user.id)
                new_email.id.should_not be_nil
                new_email.active.should == true
            end

            it "should allow de-activating" do
                @legacy_phone.update(active: false)
                @legacy_phone.should have_at_most(0).errors
                @legacy_email.update(active: false)
                @legacy_email.should have_at_most(0).errors
            end
        end

        context "identical active identifier already exists" do

            context "and its the same user" do
                it "should not create a new UserSocial" do

                    new_phone = UserSocial.create(type_of: "phone", identifier: "2222222222", user_id: @legacy_user.id)
                    new_email = UserSocial.create(type_of: "email", identifier: "ace@email.com", user_id: @legacy_user.id)
                    new_phone.id.should be_nil
                    new_email.id.should be_nil
                end
            end

            context "and its a different user" do
                it "should not create a new UserSocial" do

                    new_user = FactoryGirl.create(:user, first_name: "bob", email: "bob@email.com")
                    new_phone = UserSocial.create(type_of: "phone", identifier: "2222222222", user_id: @legacy_user.id, active: true)
                    new_email = UserSocial.create(type_of: "email", identifier: "ace@email.com", user_id: @legacy_user.id, active: true)
                    new_phone.id.should be_nil
                    new_email.id.should be_nil
                    new_phone.errors.messages[:phone].should include("is already in use. Please email support@itson.me for assistance if this is in error")
                    new_email.errors.messages[:email].should include("is already in use. Please email support@itson.me for assistance if this is in error")
                end
            end
        end

        context "identical deactivated identifier already exists" do

            before do
                @legacy_phone.toggle!(:active)
                @legacy_email.toggle!(:active)
            end

            context "and its the same user" do
                it "should activate the existing user social" do
                    new_phone = UserSocial.create(type_of: "phone", identifier: "2222222222", user_id: @legacy_user.id)
                    new_email = UserSocial.create(type_of: "email", identifier: "ace@email.com", user_id: @legacy_user.id)
                    new_phone.id.should_not be_nil
                    new_email.id.should_not be_nil
                    new_phone.active.should == true
                    new_email.active.should == true
                    @legacy_phone.active.should == false
                    @legacy_email.active.should == false
                end
            end

            context "different user" do
                it "should create a new user social" do
                    new_phone = UserSocial.create(type_of: "phone", identifier: "2222222222", user_id: @legacy_user.id)
                    new_email = UserSocial.create(type_of: "email", identifier: "ace@email.com", user_id: @legacy_user.id)
                    new_phone.id.should_not be_nil
                    new_email.id.should_not be_nil
                    new_phone.active.should == true
                    new_email.active.should == true
                    @legacy_phone.active.should == false
                    @legacy_email.active.should == false
                end
            end
        end
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
#  subscribed :boolean         default(FALSE)
#  name       :string(255)
#  birthday   :date
#  handle     :string(255)
#

