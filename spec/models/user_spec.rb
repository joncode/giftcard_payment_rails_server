require 'spec_helper'

describe User do

	before(:each) do
		User.delete_all
		UserSocial.delete_all
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

        it "should associate oauths as user" do
            user = FactoryGirl.create(:user)
            oauth = FactoryGirl.create(:oauth, user: user)

            user.oauths.first.id.should == oauth.id
            user.oauths.first.user_id.should == user.id
        end
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

    it "should not create user with first name (null) BUG FIX" do
        user = FactoryGirl.build(:user, first_name: "(null)")
        user.save
        user.id.should be_nil
        user.should have_at_least(1).error_on(:first_name)
        user.errors.messages[:first_name].should == ["Account creation was not successful. Please go back one screen, re-enter your first name and re-submit. Thanks."]
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

			it "should not create a new user social record if no new #{type_of} is submitted #{type_of}" do
				# update a user without #{type_of} change
				running {
						@user.update(last_name: "change_me_not_id")
				}.should_not change { UserSocial.count }

			end

            it "should not allow saving a record that already exists for another user primary #{type_of}" do
                other_user = FactoryGirl.create(:user, type_of => identifier)
                @user.update( type_of => identifier)
                @user.should have_at_least(1).error_on(type_of)
                if type_of == "phone"
                    resp_ary = ["is already in use. Please email support@itson.me for assistance if this is in error", "is already on an acount."]
                else
                    resp_ary = ["is already in use. Please email support@itson.me for assistance if this is in error", "is already on an acount, please use that to log in"]
                end
                @user.errors[type_of].should == resp_ary
            end

            it "should not allow saving a record that already exists for another user secondary #{type_of}" do
                other_user = FactoryGirl.create(:user, type_of => identifier)
                new_primary = "4568759687"
                new_primary = "newprimary@gmail.com" if type_of == "email"
                other_user.update(type_of => new_primary)
                @user.update( type_of => identifier)

                @user.should have_at_least(1).error_on(type_of)
                @user.errors[type_of].should == ["is already in use. Please email support@itson.me for assistance if this is in error"]
            end

            it "should allow saving a record that already exists for another user secondary but deactivated #{type_of}" do
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

        it "should send push to gift giver when this user is the receiver of an incomplete gift" do
            ResqueSpec.reset!
            MailerJob.stub(:perform).and_return(true)
            SubscriptionJob.stub(:perform).and_return(true)
            gift = FactoryGirl.create(:gift, receiver_id: nil, receiver_email: "new_push@tarantino.com")
            if gift.status == 'unpaid'
                gift.update(status: 'incomplete')
            else
                gift.status.should == 'incomplete'
            end
            pnt2  = "AWESOMEFUKINTOKENSAWESOMEFUCKINTOKENS"
            giver = gift.giver
            giver.pn_token = pnt2
            giver.pn_token.should == [pnt2]

            ResqueSpec.reset!
            MailerJob.stub(:perform).and_return(true)
            SubscriptionJob.stub(:perform).and_return(true)
            stub_request(:put, "https://q_NVI6G1RRaOU49kKTOZMQ:yQEhRtd1QcCgu5nXWj-2zA@go.urbanairship.com/api/device_tokens/162cbf28c4c94eeff8dbc3ec489581568768bbdd43c549d089deaa622a833d76").to_return(:status => 200, :body => "", :headers => {})
            pnt  = "162cbf28c4c94eeff8dbc3ec489581568768bbdd43c549d089deaa622a833d76"
            receiver = FactoryGirl.create :user, { first_name: "Quentin", email: "new_push@tarantino.com" }
            receiver.pn_token = pnt
            receiver.pn_token.should == [pnt]
            ua_alias_thing = giver.pn_tokens.first.ua_alias
            Urbanairship.should_receive(:push).with({:aliases=>[ua_alias_thing], :aps=>{:alert=>"Thank You! Quentin Basic got the app and your gift!", :badge=>0, :sound=>"pn.wav"}, :alert_type=>2})
            run_delayed_jobs
        end

        it "should not send push to gift giver when giver is not a user is the receiver of an incomplete gift" do
            ResqueSpec.reset!
            MailerJob.stub(:perform).and_return(true)
            SubscriptionJob.stub(:perform).and_return(true)
            gift = FactoryGirl.build(:gift, receiver_id: nil, receiver_email: "new_push@tarantino.com")
            provider = FactoryGirl.create(:provider)
            biz_user = provider.biz_user
            gift.giver = biz_user
            if gift.status == 'unpaid'
                gift.update(status: 'incomplete')
            else
                gift.status.should == 'incomplete'
            end

            ResqueSpec.reset!
            MailerJob.stub(:perform).and_return(true)
            SubscriptionJob.stub(:perform).and_return(true)
            stub_request(:put, "https://q_NVI6G1RRaOU49kKTOZMQ:yQEhRtd1QcCgu5nXWj-2zA@go.urbanairship.com/api/device_tokens/162cbf28c4c94eeff8dbc3ec489581568768bbdd43c549d089deaa622a833d76").to_return(:status => 200, :body => "", :headers => {})
            pnt  = "162cbf28c4c94eeff8dbc3ec489581568768bbdd43c549d089deaa622a833d76"
            receiver = FactoryGirl.create :user, { first_name: "Quentin", email: "new_push@tarantino.com" }
            receiver.pn_token = pnt
            receiver.pn_token.should == [pnt]

            Urbanairship.should_not_receive(:push).with({:aliases=>["user-649388"], :aps=>{:alert=>"Thank You! Quentin Basic got the app and your gift!", :badge=>0, :sound=>"pn.wav"}, :alert_type=>2})
            run_delayed_jobs
        end
    end

    context "user has contacts ducktype tests" do

        context "custom_validation" do

            it "validates uniqueness / presence of primary email on user record" do
                user = FactoryGirl.build(:user, :email => nil)
                user.should_not be_valid
                user.should have_at_least(1).error_on(:email)
            end

            it "accepts nil as email for a deactivated user record save" do
                user = FactoryGirl.build(:user, :email => nil, perm_deactive: true)
                user.should be_valid
                user.should_not have_at_least(1).error_on(:email)
            end
        end

        context "user status" do

            it "can suspend a user" do
                user = FactoryGirl.create(:user)
                user.suspend
                #test for suspension
            end

            it "can unsuspend a user" do

            end

            it "can deactivate a user account" do
                # has all deactivated user_socials
                # has no primary contact info on deactiavted record
            end

            it "cannot re-activate a deactivated user account" do

            end

        end

        context :email do

            it "can add an secondary email" do
                user = FactoryGirl.create(:user)
                primary_email = user.email
                primary_email.should_not be_nil

                user.update(email: "new_email@gmail.com")
                user.email.should == primary_email
                new_email = user.user_socials.where(type_of: "email", identifier: "new_email@gmail.com").first
                new_email.identifier.should == "new_email@gmail.com"
            end

            it "cannot deactivate primary email" do
                user = FactoryGirl.create(:user)
                primary_email = user.email
                primary_email.should_not be_nil
                user.user_socials.where(type_of: "email").count.should == 1
                user.deactivate_social(:email,  primary_email)
                contact = UserSocial.unscoped.find_by(identifier: primary_email)
                contact.active.should be_true
            end

            it "can deactivate while promoting an active secondary to primary" do
                user = FactoryGirl.create(:user)
                primary_email = user.email
                primary_email.should_not be_nil
                user.update(email: "new_email@gmail.com")
                user.user_socials.where(type_of: "email").count.should == 2
                user.deactivate_social(:email,  primary_email)
                contact = UserSocial.find_by(identifier: "new_email@gmail.com")
                contact.active.should be_true
                contact = UserSocial.unscoped.find_by(identifier: primary_email)
                contact.active.should be_false
                user.email.should == "new_email@gmail.com"
            end

            it "can deactivate all email acounts except primary" do
                user = FactoryGirl.create(:user)
                primary_email = user.email
                primary_email.should_not be_nil
                user.update(email: "new_email@gmail.com")
                user.update(email: "third_email@gmail.com")
                user.user_socials.where(type_of: "email").count.should == 3
                user.deactivate_social(:email,  "new_email@gmail.com")
                contact = UserSocial.unscoped.find_by(identifier: "new_email@gmail.com")
                contact.active.should be_false
                user.deactivate_social(:email,  "third_email@gmail.com")
                contact = UserSocial.unscoped.find_by(identifier: "third_email@gmail.com")
                contact.active.should be_false
                user.deactivate_social(:email,  primary_email)
                contact = UserSocial.unscoped.find_by(identifier: primary_email)
                contact.active.should be_true
            end

            it "allows you to change primary email with user social that already exists" do
                user = FactoryGirl.create(:user)
                primary_email = user.email
                primary_email.should_not be_nil
                user.update(email: "new_email@gmail.com")
                user.user_socials.where(type_of: "email").count.should == 2

                user.update(email: "new_email@gmail.com", primary: true)
                user.email.should == "new_email@gmail.com"
            end

            it "allow you to change primary email with user social that doesnt already exist" do
                user = FactoryGirl.create(:user)
                primary_email = user.email
                primary_email.should_not be_nil
                user.user_socials.where(type_of: "email").count.should == 1

                user.update(email: "new_email@gmail.com", primary: true)
                user.email.should == "new_email@gmail.com"
            end
        end

        context :phone do

            it "can add a secondary phone" do
                user = FactoryGirl.create(:user)
                primary_phone = user.phone
                primary_phone.should_not be_nil

                user.update(phone: "6568489843")
                user.phone.should == primary_phone
                new_phone = user.user_socials.where(type_of: "phone", identifier: "6568489843").first
                new_phone.identifier.should == "6568489843"
            end

            it "can deactivate primary phone - secondary phone becomes primary" do
                user = FactoryGirl.create(:user)
                primary_phone = user.phone
                primary_phone.should_not be_nil
                user.update(phone: "6467578686")
                user.user_socials.where(type_of: "phone").count.should == 2
                user.deactivate_social(:phone,  primary_phone)
                contact = UserSocial.find_by(identifier: "6467578686")
                contact.active.should be_true
                contact = UserSocial.unscoped.find_by(identifier: primary_phone)
                contact.active.should be_false
                user.phone.should == "6467578686"
            end

            it "can deactivate all phone acounts including primary and set user primary to nil" do
                user = FactoryGirl.create(:user)
                primary_phone = user.phone
                primary_phone.should_not be_nil
                user.update(phone: "6467578686")
                user.update(phone: "2123536747")
                user.user_socials.where(type_of: "phone").count.should == 3
                user.deactivate_social(:phone,  "6467578686")
                contact = UserSocial.unscoped.find_by(identifier: "6467578686")
                contact.active.should be_false
                user.deactivate_social(:phone,  "2123536747")
                contact = UserSocial.unscoped.find_by(identifier: "2123536747")
                contact.active.should be_false
                user.deactivate_social(:phone,  primary_phone)
                contact = UserSocial.unscoped.find_by(identifier: primary_phone)
                contact.active.should be_false
                user.phone.should be_nil
            end

            it "allows you to change primary phone with user social that already exists" do
                user = FactoryGirl.create(:user)
                primary_phone = user.phone
                primary_phone.should_not be_nil
                user.update(phone: "6467578686")
                user.user_socials.where(type_of: "phone").count.should == 2

                user.update(phone: "6467578686", primary: true)
                user.phone.should == "6467578686"
            end

            it "allow you to change primary phone with user social that doesnt already exist" do
                user = FactoryGirl.create(:user)
                primary_phone = user.phone
                primary_phone.should_not be_nil
                user.user_socials.where(type_of: "phone").count.should == 1

                user.update(phone: "6467578686", primary: true)
                user.phone.should == "6467578686"
            end

        end

        context :twitter do

            it "can add a twitter account" do

            end

            it "can deactivate primary twitter accounts - secondary twitter accounts becomes primary" do

            end

            it "can deactivate all  twitter accounts including primary" do

            end

            it "allows you to change primary twitter account" do

            end

        end

        context :facebook do

            it "can add a facebook account" do

            end

            it "can deactivate primary facebook accounts - secondary facebook accounts becomes primary" do

            end

            it "can deactivate all facebook accounts including primary" do

            end

            it "allows you to change primary facebook account" do

            end

        end
    end
end
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

