require 'spec_helper'

# require File.dirname(__FILE__) + '/../spec_helper'

describe Mt::V1::MerchantToolsController do

    describe "#update" do

        before do
            @provider = FactoryGirl.create :provider
        end

        it "should update provider with merchant hash" do
            merchant_hsh = serialize(@provider)
            merchant_hsh["address"] = "101 N 5th st"
            # post to the action with token, and merchant hash in normal json
            post :update, format: :json , token: merchant_hsh["token"], data: (merchant_hsh)
            # check that provider is updated with the merchant hash info
            updated_provider = Provider.find @provider.id
            updated_provider.address.should == "101 N 5th st"

        end

    end

    def make_json_merchant merchant_hsh
        merchant_hsh.to_json
    end

    def serialize provider
        provider.serializable_hash only: [:name, :address, :city, :state, :zip, :token]
    end

end