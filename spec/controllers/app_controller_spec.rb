require 'spec_helper'

describe AppController do

    before(:all) do
        User.delete_all
        Gift.delete_all
    end

    describe "#relays" do

        let(:giver)     { FactoryGirl.create(:giver) }
        let(:receiver)  { FactoryGirl.create(:receiver) }

        before(:each) do

            @number = 10
            @number.times do |n|
                gift =  FactoryGirl.build(:gift)
                gift.add_giver(giver)
                gift.add_receiver(receiver)
                gift.save
            end
        end

        it "should return a correct badge count" do
            post :relays, format: :json, token: receiver.remember_token
            #puts json.inspect + "   <----  JSON  <----"
            json["success"]["badge"].should == @number
        end

        it "should return gifts with deactivated givers" do
            giver.update_attribute(:active, false)
            post :relays, format: :json, token: receiver.remember_token
            #puts json.inspect + "   <----  JSON  <----"
            json["success"]["badge"].should == @number
        end

        it "should not return gifts with deactivated receivers" do
            receiver.update_attribute(:active, false)
            post :relays, format: :json, token: receiver.remember_token
            #puts json.inspect + "   <----  JSON  <----"
            json["error"].should == {"user"=>"could not identity app user"}
        end

        it "should not return gifts that are unpaid" do
            gs = Gift.all
            total_changed = 0
            skip_first = false
            skip_second = false
            gs.each do |gift|
                if gift.id.even? && skip_first && skip_second
                    gift.update_attribute(:pay_stat, "unpaid")
                    total_changed += 1
                else
                    gift.update_attribute(:pay_stat, "charged")
                    if skip_first
                        skip_second = true
                    end
                    skip_first = true
                end
            end
            post :relays, format: :json, token: receiver.remember_token
            json["success"]["badge"].should == (@number - total_changed)
        end

    end

    describe "#drinkboard_users" do

        let(:user) { FactoryGirl.create(:user) }
        let(:deactivated) { FactoryGirl.create(:user, active: false ) }


        it "should return array of drinkboard users" do
            post :drinkboard_users, format: :json, token: user.remember_token
            response.status.should == 200
            json.class.should      == Array
        end

        it "should return users from deactivated user" do
            post :drinkboard_users, format: :json, token: deactivated.remember_token
            response.status.should == 200
            puts "JSON --->>>  #{json}"
            #json["error"].should == "cannot find user from token"
            json.class.should == Array
        end

    end

    describe :update_user do

        let(:user) { FactoryGirl.create(:user) }

        context "authorization" do

            it "should not allow unauthenticated access" do
                post :update_user, format: :json, token: "No_Entrance"
                response.response_code.should == 200
                json["error"].should   == "App needs to be reset. Please log out and log back in."
            end

        end

        it "should require a update_user hash" do
            post :update_user, format: :json, token: user.remember_token, data: "update_userd data"
            json["error"].should   == "App needs to be reset. Please log out and log back in."
            post :update_user, format: :json, token: user.remember_token, data: nil
            json["error"].should   == "App needs to be reset. Please log out and log back in."
            post :update_user, format: :json, token: user.remember_token
            json["error"].should   == "App needs to be reset. Please log out and log back in."
        end

        it "should return user hash when success" do
            post :update_user, format: :json, token: user.remember_token, data: { "first_name" => "Steve"}
            response.response_code.should == 200
            json["success"].class.should  == Hash
        end

        it "should return validation errors" do
            post :update_user, format: :json, token: user.remember_token, data: { "email" => "" }
            json["error_server"].class.should    == Hash
            json["error_server"]["email"].should == "is invalid"
        end

        {
            first_name: "Ray",
            last_name:  "Davies",
            email: "ray@davies.com",
            phone: "5877437859",
            birthday: "10/10/1971",
            sex: "female",
            zip: "85733",
            phone: "(702) 410-9605"
        }.stringify_keys.each do |type_of, value|

            it "should update the user #{type_of} in database" do
                post :update_user, format: :json, token: user.remember_token, data: { type_of => value }
                new_user = user.reload
                value = "7024109605" if value == "(702) 410-9605"
                new_user.send(type_of).should == value
            end
        end

        it "should not update attributes that dont exist and succeed" do
            hsh = { "house" => "chill" }
            post :update_user, format: :json, token: user.remember_token, data: hsh
            json["success"].class.should  == Hash
        end

        it "should not update attributes that  are not allowed and succeed" do
            hsh = { "password" => "doNOTallow", "remember_token" => "DO_NOT_ALLOW" }
            post :update_user, format: :json, token: user.remember_token, data: hsh
            json["success"].class.should  == Hash
        end
    end


    describe "mailchimp resque" do

        before do
            ResqueSpec.reset!
            @user = FactoryGirl.create :user, {first_name:"Bob", last_name:"Barker", email:"first@email.com"}
            MailchimpList.any_instance.stub(:subscribe).and_return({"email" => @user.email})
            run_delayed_jobs
        end

        it "should hit subscription job with correct user social id" do
            last_us_id = UserSocial.last.id
            SubscriptionJob.should_receive(:perform).with(last_us_id + 1)
            post :update_user, format: :json, token: @user.remember_token, data: { "email" => "second@email.com" }
            run_delayed_jobs
        end        

        describe "should send email correctly" do
            it "see subscription_job_spec"
        end
    end

end