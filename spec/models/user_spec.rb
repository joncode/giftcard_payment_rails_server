require 'spec_helper'

describe User do

  it "should downcase email" do
    user = FactoryGirl.create :user, { email: "KJOOIcode@yahoo.com" }
    user.email.should == "kjooicode@yahoo.com"
    puts user.inspect
  end
  # if user social methods are called on user , it gets the data from user social

  # if user updates email, phone, twitter or facebook the data is saved in userSocial
  describe "user_social de-normalization" do

    before do
        @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
    end

    {
        email: "jon@gmail.com",
        phone: "9173706969",
        facebook_id: "123",
        twitter: "999"
    }.stringify_keys.each do |type_of, identifier|

        it "should update user #{type_of} saved new #{type_of} to user_social.rb" do
            running {
                @user.update_attribute("#{type_of}", identifier)
            }.should change { UserSocial.count }.by(1)
            user_social = UserSocial.last
            user_social.identifier.should == identifier
            user_social.type_of.should    == type_of
            user_social.user_id.should    == @user.id
        end

        it "should not create a new user social record if no new #{type_of} is submitted" do
            # update a user without #{type_of} change
            running {
                @user.update_attribute(:last_name, "replace_me")
            }.should_not change { UserSocial.count }

        end
    end

  end



end