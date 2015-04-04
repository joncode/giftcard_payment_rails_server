require 'spec_helper'

describe Admt::V2::ProvidersController do

    before(:each) do
        Provider.delete_all

         # should require valid admin credentials in every spec
        FactoryGirl.create(:admin_user, remember_token: "Token")
        request.env["HTTP_TKN"] = "Token"
    end

    describe "#deactivate" do

        it_should_behave_like("token authenticated", :put, :deactivate, id: 1)

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

    describe :update do
        before do
            @provider = FactoryGirl.create(:provider, name:"old_name",
                                                      address:"old address",
                                                      city: "old city",
                                                      state: "NY",
                                                      zip: "22222",
                                                      phone: "2222222222",
                                                      pos_merchant_id: "11111",
                                                      zinger: "old zinger",
                                                      description: "old description")
        end
      it "should update name" do
        put :update, id: @provider.id, format: :json, data: {name: "new_name"}
        @provider.reload
        @provider.name.should == "new_name"
      end
      it "should update address" do
        put :update, id: @provider.id, format: :json, data: {address: "new address"}
        @provider.reload
        @provider.address.should == "new address"
      end
      it "should update phone" do
        put :update, id: @provider.id, format: :json, data: {phone: "3333333333"}
        @provider.reload
        @provider.phone.should == "3333333333"
      end
      it "should update pos_merchant_id" do
        put :update, id: @provider.id, format: :json, data: { pos_merchant_id: "33333" }
        @provider.reload
        @provider.pos_merchant_id.should == "33333"
      end
      it "should no update unacceptable attributes" do
        put :update, id: @provider.id, format: :json, data: {live: true}
        @provider.reload
        @provider.live.should_not == true
      end
    end


    describe "#update_mode" do

        it_should_behave_like("token authenticated", :put, :update_mode, id: 1)

        it "should make 'paused' provider 'coming soon'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:paused, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "coming_soon"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "coming_soon"
        end

        it "should make 'paused' provider 'live'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:paused, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json, data: "live"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "live"
        end

        it "should make 'live' provider 'coming soon'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json, data: "coming_soon"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "coming_soon"
        end

        it "should make 'live' provider 'paused'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:live, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "paused"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "paused"
        end

        it "should make 'coming soon' provider 'live'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "live"
            new_provider = Provider.find(provider.id)
            new_provider.mode.should == "live"
        end

        it "should make 'coming soon' provider 'paused'" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "paused"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "paused"
        end

        it "should not change mode for incorrect mode and return error" do
            merchant  = FactoryGirl.create(:merchant)
            provider = FactoryGirl.create(:coming_soon, merchant_id: merchant.id )
            post :update_mode, id: provider.id, format: :json,  data: "wrong"
            new_provider = Provider.unscoped.find(provider.id)
            new_provider.mode.should == "coming_soon"
            json["status"].should == 0
            json["data"].should   == "Incorrect merchant mode sent - < wrong >"
        end

    end

end