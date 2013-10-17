require 'spec_helper'

describe Admt::V2::ProvidersController do

    before(:each) do
        Provider.delete_all

         # should require valid admin credentials in every spec
        FactoryGirl.create(:admin_user, remember_token: "Token")
        request.env["HTTP_TKN"] = "Token"
    end

    describe "#deactivate" do

        it "should deactivate 'live' provider" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            @new_provider = Provider.unscoped.find(provider.id)
            @new_provider.active.should be_false
        end

        it "should deactivate 'coming soon' provider" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            @new_provider = Provider.unscoped.find(provider.id)
            @new_provider.active.should be_false
        end

        it "should deactivate 'paused' provider" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:paused, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            @new_provider = Provider.unscoped.find(provider.id)
            @new_provider.active.should be_false
        end

        it "should deactivate merchant in MT" do
            merchant  = FactoryGirl.create(:merchant)
            provider  = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :deactivate, id: provider.id, format: :json, data: "deactivate"
            new_provider = Provider.unscoped.find(provider.id)
            merchant = new_provider.merchant
            merchant.active.should be_false
        end

    end

    describe "#update_mode" do

        it "should make 'paused' provider 'coming soon'" do
            provider = FactoryGirl.create(:paused)
            post :update_mode, id: provider.id, format: :json,  data: "coming_soon"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "coming_soon"
        end

        it "should make 'paused' provider 'live'" do
            provider = FactoryGirl.create(:paused)
            post :update_mode, id: provider.id, format: :json, data: "live"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "live"
        end

        it "should make 'live' provider 'coming soon'" do
            provider = FactoryGirl.create(:live)
            post :update_mode, id: provider.id, format: :json, data: "coming_soon"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "coming_soon"
        end

        it "should make 'live' provider 'paused'" do
            provider = FactoryGirl.create(:live)
            post :update_mode, id: provider.id, format: :json,  data: "paused"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "paused"
        end

        it "should make 'coming soon' provider 'live'" do
            provider = FactoryGirl.create(:coming_soon)
            post :update_mode, id: provider.id, format: :json,  data: "live"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "live"
        end

        it "should make 'coming soon' provider 'paused'" do
            provider = FactoryGirl.create(:coming_soon)
            post :update_mode, id: provider.id, format: :json,  data: "paused"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "paused"
        end

        it "should not change mode for incorrect mode and return error" do
            provider = FactoryGirl.create(:coming_soon)
            post :update_mode, id: provider.id, format: :json,  data: "wrong"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "coming_soon"
            json["status"].should == 0
            json["data"].should   == "Incorrect merchant mode sent - < wrong >"
        end

    end

end