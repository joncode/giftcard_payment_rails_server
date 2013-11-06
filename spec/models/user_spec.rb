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

    before(:each) do
        User.delete_all
        UserSocial.delete_all
        @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password", facebook_id: nil }
    end

    {
        email: "jon@gmail.com",
        phone: "9173706969",
        facebook_id: "123",
        twitter: "999"
    }.stringify_keys.each do |type_of, identifier|

        it "should update when user saves new #{type_of} to user_social.rb" do
            running {
                @user.update_attribute("#{type_of}", identifier)
            }.should change { UserSocial.count }.by(1)
            user_social = UserSocial.last
            user_social.identifier.should == identifier
            user_social.type_of.should    == type_of
            user_social.user_id.should    == @user.id
        end

        it "should remove #{type_of} when user deletes #{type_of}" do
            user = FactoryGirl.create :user, { "#{type_of}" => identifier }
            user.deactivate_social("#{type_of}", identifier)
            UserSocial.unscoped.find_by_identifier(identifier).active.should be_false
        end

        it "should not create a new user social record if no new #{type_of} is submitted" do
            # update a user without #{type_of} change
            running {
                @user.update_attributes({last_name: "change_me_not_id"})
            }.should_not change { UserSocial.count }

        end
    end

    # test that user_social save condensed phone numbers
    # test that user social runs email downcase and regex
    # test that user can give a primary phone number
    # test that user can give a primary email address

  end



end# == Schema Information
#
# Table name: users
#
#  id                      :integer         not null, primary key
#  email                   :string(255)     not null
#  admin                   :boolean         default(FALSE)
#  photo                   :string(255)
#  password_digest         :string(255)
#  remember_token          :string(255)     not null
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  address                 :string(255)
#  address_2               :string(255)
#  city                    :string(20)
#  state                   :string(2)
#  zip                     :string(16)
#  credit_number           :string(255)
#  phone                   :string(255)
#  first_name              :string(255)
#  last_name               :string(255)
#  facebook_id             :string(255)
#  handle                  :string(255)
#  server_code             :string(255)
#  twitter                 :string(255)
#  active                  :boolean         default(TRUE)
#  persona                 :string(255)     default("")
#  foursquare_id           :string(255)
#  facebook_access_token   :string(255)
#  facebook_expiry         :datetime
#  foursquare_access_token :string(255)
#  sex                     :string(255)
#  is_public               :boolean
#  facebook_auth_checkin   :boolean
#  iphone_photo            :string(255)
#  fb_photo                :string(255)
#  use_photo               :string(255)
#  secure_image            :string(255)
#  reset_token_sent_at     :datetime
#  reset_token             :string(255)
#  birthday                :date
#  origin                  :string(255)
#  confirm                 :string(255)     default("00")
#

