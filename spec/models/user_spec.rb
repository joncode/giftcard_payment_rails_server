require 'spec_helper'

describe User do

	before(:each) do
		User.delete_all
		UserSocial.delete_all
	end

	it "should downcase email" do
		user = FactoryGirl.create :user, { email: "KJOOIcode@yahoo.com" }
		user.email.should == "kjooicode@yahoo.com"
		puts user.inspect
	end
	# if user social methods are called on user , it gets the data from user social

	it "should accept integers for phone, twitter, facebook _id" do
		user = FactoryGirl.build :user, { twitter: 832742384, facebook_id: 318341934192, phone: 9876787657 }
		user.save
		new_user = User.find_by(twitter:  "832742384")
		new_user.phone.should == "9876787657"
		new_user.facebook_id.should == "318341934192"
	end

	it "should get photo defaut or real" do
		user  = FactoryGirl.create(:user, :iphone_photo => "test_photo")
		user.get_photo.should_not == "test_photo"
		user.get_photo.should == "http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"
		user.iphone_photo = "http://res.cloudinary.com/test_photo.jpg"
		user.save
		user.get_photo.should == "http://res.cloudinary.com/test_photo.jpg"
	end

	# if user updates email, phone, twitter or facebook the data is saved in userSocial
	describe "user_social de-normalization" do

		before(:each) do
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
				UserSocial.unscoped.find_by(identifier: identifier).active.should be_false
			end

			it "should not create a new user social record if no new #{type_of} is submitted" do
				# update a user without #{type_of} change
				running {
						@user.update_attributes({last_name: "change_me_not_id"})
				}.should_not change { UserSocial.count }

			end

            it "should not allow saving a record that already exists for another user primary" do
                other_user = FactoryGirl.create(:user, type_of => identifier)
                @user.update( type_of => identifier)
                @user.should have_at_least(1).error_on(type_of)
                @user.errors[type_of].should == ["is already in use. Please email support@itson.me for assistance if this is in error", "you already have an account with that id, please use that to log in"]
            end

            it "should not allow saving a record that already exists for another user secondary" do
                other_user = FactoryGirl.create(:user, type_of => identifier)
                new_primary = "4568759687"
                new_primary = "newprimary@gmail.com" if type_of == "email"
                other_user.update(type_of => new_primary)
                @user.update( type_of => identifier)

                @user.should have_at_least(1).error_on(type_of)
                @user.errors[type_of].should == ["is already in use. Please email support@itson.me for assistance if this is in error"]
            end

            it "should allow saving a record that already exists for another user secondary but deactivated" do
                other_user = FactoryGirl.create(:user, type_of => identifier)
                new_primary = "4568759687"
                new_primary = "newprimary@gmail.com" if type_of == "email"
                other_user.update(type_of => new_primary)
                us = UserSocial.where( type_of: type_of, identifier: identifier).first
                us.update(active: false)
                @user.update( type_of => identifier)
                @user.should have_at_least(0).error_on(type_of)
                newus = UserSocial.where( type_of: type_of, identifier: identifier, active: true).first
                newus.user_id.should == @user.id
            end
		end
	end

    context "model associations and validations" do

        it "builds from factory" do
            user = FactoryGirl.create :user
            user.should be_valid
        end

        it "should associate gift as giver" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift, giver: user)

            user.reload
            user.sent.first.id.should          == gift.id
            user.sent.first.class.should       == Gift
        end

        it "should associate gift as receiver" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift, receiver: user)

            user.reload
            user.received.first.id.should             == gift.id
            user.received.first.class.should          == Gift
        end

        it "should associate card as user" do
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:card, user: user)

            user.cards.first.id.should == card.id
            user.cards.first.user_id.should == user.id
        end

    end

    context "pn_token management" do

        it "should hit urban airship endpoint when token created or updated" do
            ResqueSpec.reset!
            MailerJob.stub(:perform).and_return(true)
            SubscriptionJob.stub(:perform).and_return(true)
            pnt  = "162cbf28c4c94eeff8dbc3ec489581568768bbdd43c549d089deaa622a833d76"
            user1 = FactoryGirl.create :user, { first_name: "Squatter", email: "KJOOIcode@yahoo.com" }
            user2 = FactoryGirl.create :user, { first_name: "Real", email: "updated@gmail.com" }

            user1.pn_token = pnt
            user1.pn_token.should == [pnt]

            user_1_alias = user1.pn_tokens.first.ua_alias
            puts "User 1 alias = #{user_1_alias}"
            Urbanairship.should_receive(:register_device).with(pnt, { :alias => user_1_alias})

            run_delayed_jobs

            user2.pn_token = pnt
            user2.pn_token.should == [pnt]

            user_2_alias = user2.pn_tokens.first.ua_alias
            puts "User 2 alias = #{user_2_alias}"
            Urbanairship.should_receive(:register_device).with(pnt, { :alias => user_2_alias})

            run_delayed_jobs

        end
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

# == Schema Information
#
# Table name: users
#
#  id                      :integer         not null, primary key
#  email                   :string(255)     not null
#  admin                   :boolean         default(FALSE)
#  password_digest         :string(255)     not null
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
#  reset_token_sent_at     :datetime
#  reset_token             :string(255)
#  birthday                :date
#  origin                  :string(255)
#  confirm                 :string(255)     default("00")
#  perm_deactive           :boolean         default(FALSE)
#

