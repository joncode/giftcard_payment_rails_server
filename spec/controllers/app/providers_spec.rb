require 'spec_helper'

describe AppController do

    describe "#providers" do
        before do
            @user            = FactoryGirl.create :user
            @first_provider  = FactoryGirl.create :provider
            @second_provider = FactoryGirl.create :provider
        end

        it "should send all providers with correct scope" do
            post :providers, format: :json, city: "New York", token: @user.remember_token
            puts json
            p_ary = json
            p_ary[0].should == @first_provider.serialize
            p_ary[1].should == @second_provider.serialize
        end
    end

end