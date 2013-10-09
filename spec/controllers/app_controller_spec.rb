require 'spec_helper'

describe AppController do

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

    end

    describe "#drinkboard_users" do

        let(:user) { FactoryGirl.create(:user) }
        let(:deactivated) { FactoryGirl.create(:user, active: false ) }

        it "should return array of drinkboard users" do
            post :drinkboard_users, format: :json, token: user.remember_token
            response.status.should == 200
            json.class.should      == Array
        end

        it "should return error from deactivated user" do
            post :drinkboard_users, format: :json, token: deactivated.remember_token
            response.status.should == 200
            puts "JSON --->>>  #{json}"
            json["error"].should == "cannot find user from token"
        end

    end

end