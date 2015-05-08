require 'spec_helper'
include MocksAndStubs
describe User do

    before(:each) do
        User.delete_all
        UserSocial.delete_all
    end

    it_should_behave_like "giver ducktype" do
        let(:object) { FactoryGirl.create(:user) }
    end

    context "model associations and validations" do

        it "should add twitter when not taken" do
            user = FactoryGirl.create(:user, twitter: "123121231")
            old_us = UserSocial.where(identifier: "294473465").first
            old_us.destroy if old_us
            us = user.update({"twitter"=> "294473465", "primary" => true})
            us = UserSocial.find_by(identifier: "294473465")
            us.type_of.should == "twitter"
        end

        it "should message app correct when twitter is already taken" do
            user = FactoryGirl.create(:user, twitter: "294473465")
            us = user.update({"twitter"=> "294473465", "primary" => true})
            us = UserSocial.find_by(identifier: "294473465")
            us.type_of.should == "twitter"
            us.should be_valid
        end

        it "builds from factory" do
            user = FactoryGirl.create :user
            user.should be_valid
        end

        it "should respond to :affiliate" do
            u = FactoryGirl.create(:user)
            a = FactoryGirl.create(:affiliate)
            u.affiliate = a
            u.affiliate.should == a
        end

        it "should respond to :affiliations" do
            m = FactoryGirl.create(:user)
            a = FactoryGirl.create(:affiliation)
            m.affiliation = a
            m.affiliation.should == a
        end

        it "should associate with session tokens" do
            user = FactoryGirl.create(:user)
            st = SessionToken.create(user_id: user.id, token: SecureRandom.urlsafe_base64)
            st2 = SessionToken.create(user_id: user.id, token: SecureRandom.urlsafe_base64)

            user.session_tokens.count.should == 3
        end

        it "should associate gift as giver" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift, giver: user)

            user.reload
            user.sent.first.id.should    == gift.id
            user.sent.first.class.should == Gift
        end

        it "should associate gift as receiver" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift, receiver: user)

            user.reload
            user.received.first.id.should    == gift.id
            user.received.first.class.should == Gift
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

        it "should associate with dittos" do
            user  = FactoryGirl.create(:user)
            ditto = FactoryGirl.create :ditto, notable_id: user.id, notable_type: user.class.to_s
            user.dittos.first.should == ditto
        end

        it "has_many app_contacts" do
            user = FactoryGirl.create(:user)
            user.app_contacts.count.should == 0
            app_contact1 = FactoryGirl.create(:app_contact)
            app_contact2 = FactoryGirl.build(:app_contact)
            app_contact2.network = "phone"
            app_contact2.network_id = "5456468756"
            app_contact2.save
            Friendship.create(user_id: user.id, app_contact_id: app_contact1.id)
            Friendship.create(user_id: user.id, app_contact_id: app_contact2.id)
            user.app_contacts.count.should == 2
            user.app_contacts[0].should == app_contact1
            user.app_contacts[1].should == app_contact2
        end
    end

    it "should have iphone_photo of 'nil' if they haven't uploaded one" do
        user = FactoryGirl.create :user, iphone_photo: nil
        user.should be_valid
        user.iphone_photo.should == nil
        user.get_photo.should    == "http://res.cloudinary.com/drinkboard/image/upload/v1398470766/avatar_blank_cvblvd.png"
    end

    it "should downcase email" do
        user = FactoryGirl.create :user, { email: "KJOOIcode@yahoo.com" }
        user.email.should == "kjooicode@yahoo.com"
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
        user.get_photo.should == "http://res.cloudinary.com/drinkboard/image/upload/v1398470766/avatar_blank_cvblvd.png"
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

    it "should update multi-socials at the same time" do
        user = FactoryGirl.create(:user, facebook_id: "111111111")
        us_count = user.user_socials.count
        #binding.pry
        user.update(facebook_id: "33333234134", email: "new_email@yahoo.com", phone: "6467334231", primary: true)
        #binding.pry
        us_count_2 = user.user_socials.count
        us_count_2.should == us_count + 3
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

            it "should remove phone from user" do
                user = FactoryGirl.create :user, { "phone" => "2222222222" }
                user.deactivate_social("phone", "2222222222")
                UserSocial.unscoped.find_by(identifier: "2222222222").active.should be_false
            end

            it "should not remove email when from user unless perm-deactive" do
                user = FactoryGirl.create :user, { "email" => "jon@gmail.com" }
                user.deactivate_social("email", "jon@gmail.com")
                UserSocial.unscoped.find_by(identifier: "jon@gmail.com").active.should be_true
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
                if type_of == "phone"
                    @user.errors[type_of].should == ["is already in use. Please email support@itson.me for assistance if this is in error", "is already on an acount."]
                else
                    @user.errors[type_of].should == ["is already in use. Please email support@itson.me for assistance if this is in error", "is already on an acount, please use that to log in"]
                end
            end

            it "should allow saving a record that already exists for another user secondary but deactivated #{type_of}" do
                other_user = FactoryGirl.create(:user, type_of => identifier)
                new_primary = "4568759687"
                new_primary = "newprimary@gmail.com" if type_of == "email"
                other_user.update(type_of => new_primary, "primary" => true)
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
            pnt  = "162cbf28c4c94eeff8dbc3ec489581568768bbdd43c549d089deaa622a833d76"
            user1 = FactoryGirl.create :user, { first_name: "Squatter", email: "KJOOIcode@yahoo.com" }
            user2 = FactoryGirl.create :user, { first_name: "Real", email: "updated@gmail.com" }
            platform = 'android'
            test_urban_airship_endpoint(platform, pnt) do
                user1.pn_token = [pnt, platform]
            end
            user1.pn_token.should == [pnt]

            user_1_alias = user1.pn_tokens.first.ua_alias

            test_urban_airship_endpoint(platform, pnt) do
                user2.pn_token = [pnt, platform]
            end
            user2.pn_token.should == [pnt]
        end

        it "should send push to gift giver when this user is the receiver of an incomplete gift" do
            gift = FactoryGirl.create(:gift, receiver_id: nil, receiver_email: "new_push@tarantino.com")
            if gift.status == 'unpaid'
                gift.update(status: 'incomplete')
            else
                gift.status.should == 'incomplete'
            end
            pnt2  = "AWESOMEFUKINTOKENSAWESOMEFUCKINTOKENS"
            giver = gift.giver
            platform = 'ios'
            test_urban_airship_endpoint(platform, pnt2) do
                giver.pn_token = [pnt2, platform]
            end
            giver.pn_token.should == [pnt2]

            pnt  = "162cbf28c4c94eeff8dbc3ec489581568768bbdd43c549d089deaa622a833d76"
            test_urban_airship_endpoint(platform, pnt) do
                receiver = FactoryGirl.create :user, { first_name: "Quentin", email: "new_push@tarantino.com"}
                Urbanairship.should_receive(:push).with({:aliases=>[giver.ua_alias], :aps=>{:alert=>"Thank You! Quentin Basic got the app and your gift!", :badge=>0, :sound=>"pn.wav"}, :alert_type=>2,:android=>{:alert=>"Thank You! Quentin Basic got the app and your gift!"}})
                receiver.pn_token = [pnt]
                receiver.pn_token.should == [pnt]
            end
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

            context "suspended user" do
                before do
                    @user = FactoryGirl.create(:user, email: "primary@email.com", phone: "2222222222", facebook_id: "111111111", twitter: "111a1a1aa1")
                    FactoryGirl.create(:user_social, type_of: "email", identifier: "new_email@email.com", user_id: @user.id)
                    FactoryGirl.create(:user_social, type_of: "phone", identifier: "3333333333", user_id: @user.id)
                    FactoryGirl.create(:user_social, type_of: "facebook_id", identifier: "2222222222", user_id: @user.id)
                    FactoryGirl.create(:user_social, type_of: "twitter", identifier: "222b2b2bb2", user_id: @user.id)
                    @user.reload
                    @hold_user = User.new(@user.serializable_hash)
                    @user.suspend
                end

                it "can suspend a user" do
                    @user.active             == false
                    @user.perm_deactive      == false
                    # @user.email.should       == @hold_user.email
                    # @user.phone.should       == @hold_user.phone
                    # @user.facebook_id.should == @hold_user.facebook_id
                    # @user.twitter.should     == @hold_user.twitter
                    UserSocial.unscoped.count.should == 8
                    UserSocial.unscoped.where(active: false).count.should == 8
                end

                it "can unsuspend a user" do
                    @user.active == false
                    @user.perm_deactive == false
                    UserSocial.unscoped.where(active: false).count.should == 8
                    @user.suspend

                    @user.active == true
                    @user.perm_deactive == false
                    # @user.email.should       == @hold_user.email
                    # @user.phone.should       == @hold_user.phone
                    # @user.facebook_id.should == @hold_user.facebook_id
                    # @user.twitter.should     == @hold_user.twitter
                    UserSocial.unscoped.count.should == 8
                    UserSocial.unscoped.where(active: false).count.should == 0
                    UserSocial.unscoped.where(active: true).count.should == 8
                end
            end

            context "perm-deactivated user" do
                before do
                    @user = FactoryGirl.create(:user, email: "primary@email.com", phone: "2222222222", facebook_id: "111111111", twitter: "111a1a1aa1")
                    FactoryGirl.create(:user_social, type_of: "email", identifier: "new_email@email.com", user_id: @user.id)
                    FactoryGirl.create(:user_social, type_of: "phone", identifier: "3333333333", user_id: @user.id)
                    FactoryGirl.create(:user_social, type_of: "facebook_id", identifier: "2222222222", user_id: @user.id)
                    FactoryGirl.create(:user_social, type_of: "twitter", identifier: "222b2b2bb2", user_id: @user.id)
                    @user.permanently_deactivate
                end

                it "can perm-deactivate a user" do
                    @user.active == false
                    @user.perm_deactive == true
                    @user.email.should == nil
                    @user.phone.should == nil
                    @user.facebook_id.should == nil
                    @user.twitter.should == nil
                    UserSocial.unscoped.count.should == 8
                    UserSocial.unscoped.where(active: false).count.should == 8
                end

                it "can un-perm-deactivate a user" do
                    @user.active == false
                    @user.perm_deactive == true
                    UserSocial.unscoped.where(active: false).count.should == 8
                    @user.update(perm_deactive: false)

                    @user.active == false
                    @user.perm_deactive == true
                    @user.email.should == nil
                    @user.phone.should == nil
                    @user.facebook_id.should == nil
                    @user.twitter.should == nil
                    UserSocial.unscoped.count.should == 8
                    UserSocial.unscoped.where(active: false).count.should == 8
                    UserSocial.unscoped.where(active: true).count.should == 0
                end
            end
        end

        context :email do

            it "can add a secondary email" do
                user = FactoryGirl.create(:user, email: "primary_email@email.com")
                user.update(email: "new_email@gmail.com")

                user.email.should == "primary_email@email.com"
                user_emails = user.user_socials.where(type_of: "email")
                user_emails.count.should == 2
                user_emails.where.not(identifier: "primary_email@email.com").first.identifier.should == "new_email@gmail.com"
            end

            it "cannot deactivate primary email" do
                user = FactoryGirl.create(:user, email: "primary_email@email.com")

                user.user_socials.where(type_of: "email").count.should == 1
                user.deactivate_social(:email,  "primary_email@email.com")
                contact = UserSocial.unscoped.where(identifier: "primary_email@email.com").first
                contact.active.should be_true
            end

            it "can deactivate while promoting an active secondary to primary" do
                user = FactoryGirl.create(:user, email: "primary_email@email.com")
                FactoryGirl.create(:user_social, type_of: "email", identifier: "new_email@email.com", user_id: user.id)

                user.user_socials.where(type_of: "email").count.should == 2
                user.deactivate_social(:email,  "primary_email@email.com")
                contact = UserSocial.find_by(identifier: "new_email@email.com")
                contact.active.should be_true
                contact = UserSocial.unscoped.find_by(identifier: "primary_email@email.com")
                contact.active.should be_false
                user.email.should == "new_email@email.com"
            end

            it "can deactivate all email acounts except primary" do
                user = FactoryGirl.create(:user, email: "primary@email.com")
                FactoryGirl.create(:user_social, type_of: "email", user_id: user.id, identifier: "second@email.com")
                FactoryGirl.create(:user_social, type_of: "email", user_id: user.id, identifier: "third@email.com")
                user.user_socials.where(type_of: "email").count.should == 3

                user.deactivate_social(:email,  "second@email.com")
                contact = UserSocial.unscoped.find_by(identifier: "second@email.com")
                contact.active.should be_false
                user.deactivate_social(:email,  "third@email.com")
                contact = UserSocial.unscoped.find_by(identifier: "third@email.com")
                contact.active.should be_false
                user.deactivate_social(:email,  "primary@email.com")
                contact = UserSocial.unscoped.find_by(identifier: "primary@email.com")
                contact.active.should be_true
            end

            it "allows you to change primary email with user social that already exists" do
                user = FactoryGirl.create(:user, email:"primary@email.com")
                FactoryGirl.create :user_social, type_of: "email", user_id: user.id, identifier: "secondary@email.com"
                user.user_socials.where(type_of: "email").count.should == 2

                user.update(email: "secondary@email.com", primary: true)
                user.email.should == "secondary@email.com"
                user.user_socials.where(type_of: "email").count.should == 2
            end

            it "allow you to change primary email with user social that doesnt already exist" do
                user = FactoryGirl.create(:user, email: "primary@email.com")
                user.user_socials.where(type_of: "email").count.should == 1

                user.update(email: "new_email@gmail.com", primary: true)
                user.email.should == "new_email@gmail.com"
                user.user_socials.where(type_of: "email").count.should == 2
            end
        end

        context :phone do

            it "can add a secondary phone" do
                user = FactoryGirl.create(:user, phone: "2222222222")
                FactoryGirl.create :user_social, type_of: "phone", user_id: user.id, identifier: "3333333333"

                user.phone.should == "2222222222"
                user_phones = user.user_socials.where(type_of: "phone")
                user_phones.count.should == 2
                user_phones.where.not(identifier: "2222222222").first.identifier.should == "3333333333"
            end

            it "can deactivate primary phone - secondary phone becomes primary" do
                user = FactoryGirl.create(:user, phone: "2222222222")
                FactoryGirl.create :user_social, type_of: "phone", user_id: user.id, identifier: "3333333333"

                user.user_socials.where(type_of: "phone").count.should == 2
                user.deactivate_social(:phone,  "2222222222")
                contact = UserSocial.find_by(identifier: "3333333333")
                contact.active.should be_true
                contact = UserSocial.unscoped.find_by(identifier: "2222222222")
                contact.active.should be_false
                user.phone.should == "3333333333"
            end

            it "can deactivate all phone acounts including primary and set user primary to nil" do
                user = FactoryGirl.create(:user, phone: "2222222222")
                FactoryGirl.create :user_social, type_of: "phone", user_id: user.id, identifier: "3333333333"
                FactoryGirl.create :user_social, type_of: "phone", user_id: user.id, identifier: "4444444444"

                user.user_socials.where(type_of: "phone").count.should == 3
                user.deactivate_social(:phone,  "4444444444")
                contact = UserSocial.unscoped.find_by(identifier: "4444444444")
                contact.active.should be_false
                user.deactivate_social(:phone,  "3333333333")
                contact = UserSocial.unscoped.find_by(identifier: "3333333333")
                contact.active.should be_false
                user.deactivate_social(:phone,  "2222222222")
                contact = UserSocial.unscoped.find_by(identifier: "2222222222")
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

            it "should extract phone digits from dashed number on update" do
                user = FactoryGirl.create(:user)
                user.update(phone: "555-333-4567")
                UserSocial.where(identifier: "555-333-4567").should_not be_present
                UserSocial.where(identifier: "5553334567").should be_present
            end

        end

        context :twitter do

            it "can add a secondary twitter" do
                user = FactoryGirl.create(:user, twitter: "111a1a1aa1")
                FactoryGirl.create :user_social, type_of: "twitter", user_id: user.id, identifier: "222b2b2bb2"

                user.twitter.should == "111a1a1aa1"
                user_twitters = user.user_socials.where(type_of: "twitter")
                user_twitters.count.should == 2
                user_twitters.where.not(identifier: "111a1a1aa1").first.identifier.should == "222b2b2bb2"
            end

            it "can deactivate primary twitter - secondary twitter becomes primary" do
                user = FactoryGirl.create(:user, twitter: "111a1a1aa1")
                FactoryGirl.create :user_social, type_of: "twitter", user_id: user.id, identifier: "222b2b2bb2"

                user.user_socials.where(type_of: "twitter").count.should == 2
                user.deactivate_social(:twitter,  "111a1a1aa1")
                contact = UserSocial.find_by(identifier: "222b2b2bb2")
                contact.active.should be_true
                contact = UserSocial.unscoped.find_by(identifier: "111a1a1aa1")
                contact.active.should be_false
                user.twitter.should == "222b2b2bb2"
            end

            it "can deactivate all twitter acounts including primary and set user primary to nil" do
                user = FactoryGirl.create(:user, twitter: "111a1a1aa1")
                FactoryGirl.create :user_social, type_of: "twitter", user_id: user.id, identifier: "222b2b2bb2"
                FactoryGirl.create :user_social, type_of: "twitter", user_id: user.id, identifier: "4444444444"

                user.user_socials.where(type_of: "twitter").count.should == 3
                user.deactivate_social(:twitter,  "4444444444")
                contact = UserSocial.unscoped.find_by(identifier: "4444444444")
                contact.active.should be_false
                user.deactivate_social(:twitter,  "222b2b2bb2")
                contact = UserSocial.unscoped.find_by(identifier: "222b2b2bb2")
                contact.active.should be_false
                user.deactivate_social(:twitter,  "111a1a1aa1")
                contact = UserSocial.unscoped.find_by(identifier: "111a1a1aa1")
                contact.active.should be_false
                user.twitter.should be_nil
            end

            it "allows you to change primary twitter with user social that already exists" do
                user = FactoryGirl.create(:user, twitter: "111a1a1aa1")
                FactoryGirl.create :user_social, type_of: "twitter", user_id: user.id, identifier: "222b2b2bb2"
                user.reload
                user.user_socials.where(type_of: "twitter").count.should == 2

                user.update(twitter: "222b2b2bb2", primary: true)
                user.twitter.should == "222b2b2bb2"
                user.reload
                user.user_socials.where(type_of: "twitter").count.should == 2
            end

            it "allow you to change primary twitter with user social that doesnt already exist" do
                user = FactoryGirl.create(:user, twitter: "111a1a1aa1")
                user.user_socials.where(type_of: "twitter").count.should == 1

                user.update(twitter: "222b2b2bb2", primary: true)
                user.twitter.should == "222b2b2bb2"
            end
        end

        context :facebook do

            it "can add a secondary facebook_id" do
                user = FactoryGirl.create(:user, facebook_id: "111111111" )
                FactoryGirl.create :user_social, type_of: "facebook_id", user_id: user.id, identifier: "222222222"

                user.facebook_id.should == "111111111"
                user_facebook_ids = user.user_socials.where(type_of: "facebook_id")
                user_facebook_ids.count.should == 2
                user_facebook_ids.where.not(identifier: "111111111").first.identifier.should == "222222222"
            end

            it "can deactivate primary facebook_id - secondary facebook_id becomes primary" do
                user = FactoryGirl.create(:user, facebook_id: "111111111")
                FactoryGirl.create :user_social, type_of: "facebook_id", user_id: user.id, identifier: "222222222"

                user.user_socials.where(type_of: "facebook_id").count.should == 2
                user.deactivate_social(:facebook_id,  "111111111")
                contact = UserSocial.find_by(identifier: "222222222")
                contact.active.should be_true
                contact = UserSocial.unscoped.find_by(identifier: "111111111")
                contact.active.should be_false
                user.facebook_id.should == "222222222"
            end

            it "can deactivate all facebook_id acounts including primary and set user primary to nil" do
                user = FactoryGirl.create(:user, facebook_id: "111111111")
                FactoryGirl.create :user_social, type_of: "facebook_id", user_id: user.id, identifier: "222222222"
                FactoryGirl.create :user_social, type_of: "facebook_id", user_id: user.id, identifier: "333333333"

                user.user_socials.where(type_of: "facebook_id").count.should == 3
                user.deactivate_social(:facebook_id,  "333333333")
                contact = UserSocial.unscoped.find_by(identifier: "333333333")
                contact.active.should be_false
                user.deactivate_social(:facebook_id,  "222222222")
                contact = UserSocial.unscoped.find_by(identifier: "222222222")
                contact.active.should be_false
                user.deactivate_social(:facebook_id,  "111111111")
                contact = UserSocial.unscoped.find_by(identifier: "111111111")
                contact.active.should be_false
                user.facebook_id.should be_nil
            end

            it "allows you to change primary facebook_id with user social that already exists" do
                user = FactoryGirl.create(:user, facebook_id: "111111111")
                FactoryGirl.create :user_social, type_of: "facebook_id", user_id: user.id, identifier: "222222222"
                user.user_socials.where(type_of: "facebook_id").count.should == 2

                user.update(facebook_id: "222222222", primary: true)
                user.facebook_id.should == "222222222"
                user.user_socials.where(type_of: "facebook_id").count.should == 2
            end

            it "allow you to change primary facebook_id with user social that doesnt already exist" do
                user = FactoryGirl.create(:user, facebook_id: "111111111")
                user.user_socials.where(type_of: "facebook_id").count.should == 1

                user.update(facebook_id: "222222222", primary: true)
                user.facebook_id.should == "222222222"
            end
        end
    end

    context "friend maker" do

        before(:each) do
            ResqueSpec.reset!
            MailerJob.stub(:perform).and_return(true)
            SubscriptionJob.stub(:perform).and_return(true)
            Urbanairship.stub(:push).and_return(true)
        end

        # it "should call relationships when user is created" do
        #     # create a user with user socials
        #     user = FactoryGirl.create(:user)
        #     #FriendPushJob.should_receive(:perform).with(user.id, 1)
        #     FriendMaker.should_receive(:user_create).with(user.id)
        #     run_delayed_jobs
        # end

        # it "should call relationships when user socials are updated" do
        #     # create a user with user socials
        #     user = FactoryGirl.create(:user)
        #     run_delayed_jobs

        #     user.update(email: "newforpush@friend.com")
        #     FriendMaker.should_receive(:user_create).with(user.id)
        #     run_delayed_jobs

        #     user.update(email: "newforpush@friend.com")
        #     FriendMaker.should_receive(:user_create, primary: true).with(user.id)
        #     run_delayed_jobs

        #     user.update(phone: "7876567432")
        #     FriendMaker.should_receive(:user_create).with(user.id)
        #     run_delayed_jobs

        #     user.update(twitter: "987654321")
        #     FriendMaker.should_receive(:user_create).with(user.id)
        #     run_delayed_jobs

        #     FriendMaker.should_receive(:user_create).with(user.id)
        #     user.update(facebook_id: "75847539845", primary: true)
        #     run_delayed_jobs

        #     FriendMaker.should_receive(:user_create).with(user.id)
        #     user.update(facebook_id: "75847529245")
        #     run_delayed_jobs
        # end

        it "should not call relationships when user socials are not updated" do
            # create a user with user socials
            user = FactoryGirl.create(:user)
            run_delayed_jobs

            user.update(last_name: "nofriendpush")
            #FriendPushJob.should_not_receive(:perform).with(user.id, 1)
            FriendMaker.should_not_receive(:user_create).with(user.id)
            run_delayed_jobs
        end
    end

    context "meta_search" do
      before do
        @user1 = FactoryGirl.create(:user,
                                    first_name: "One",
                                    last_name: "User",
                                    email: "one.user@example.com",
                                    address: "123 User St",
                                    city: "OneCity",
                                    state: "OC",
                                    zip: "12345",
                                    phone: "2345679955",
                                    address_2: "another address line"
                                  )
        @user2 = FactoryGirl.create(:user, first_name: "Two", last_name: "User")
        @user3 = FactoryGirl.create(:user, first_name: "Three", last_name: "User")
      end

      xit "should find a user" do
        result = User.meta_search(@user1.first_name)
        expect(result.length).to eq(1)
        expect(result).to include(@user1)
      end

      xit "should find multiple users with common data" do
        result = User.meta_search(@user1.last_name)
        expect(result.length).to eq(3)
        [@user1, @user2, @user3].each do |user|
          expect(result).to include(user)
        end
      end

      xit "should not find users that do not exist" do
        result = User.meta_search("not_valid")
        expect(result.length).to eq(0)
      end

      xit "should find data via all expected columns" do
        terms = [
          @user1.id.to_s, #id
          "one.user@example.com", #email
          "One", #first_name
          "User", #last_name
          "123 User St", #address
          "OneCity", #city
          "oc", #state
          "12345", #zip
          "2345679955", #phone
          "another address line" #address_2
        ]

        result = User.meta_search(terms.join(" "))
        expect(result.length).to eq(1)
        expect(result).to include(@user1)
      end
    end
end
# == Schema Information
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  email               :string(255)
#  password_digest     :string(255)     not null
#  remember_token      :string(255)     not null
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  address             :string(255)
#  address_2           :string(255)
#  city                :string(20)
#  state               :string(2)
#  zip                 :string(16)
#  phone               :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  facebook_id         :string(255)
#  handle              :string(255)
#  twitter             :string(255)
#  active              :boolean         default(TRUE)
#  persona             :string(255)     default("")
#  sex                 :string(255)
#  is_public           :boolean
#  iphone_photo        :string(255)
#  reset_token_sent_at :datetime
#  reset_token         :string(255)
#  birthday            :date
#  origin              :string(255)
#  confirm             :string(255)     default("00")
#  perm_deactive       :boolean         default(FALSE)
#  cim_profile         :string(255)
#  ftmeta              :tsvector
#  affiliate_url_name  :string(255)
#


