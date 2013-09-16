require 'spec_helper'

# require File.dirname(__FILE__) + '/../spec_helper'

describe Mt::V1::MerchantToolsController do

    describe "#update" do

        before do
            @provider = FactoryGirl.create :provider
        end

        {
            name: "jonns",
            address: "101 N 5th st",
            city: "Malibu",
            state: "CA",
            zip: "94057",
            zinger: "fake zinger",
            description: "totally fake description",
            phone: "2152000098"
        }.stringify_keys.each do |type_of, identifier|

            it "should update #{type_of} on provider" do
                merchant_hsh = serialize(@provider)
                merchant_hsh[type_of] = identifier
                merchant_hsh["tz"] = "0"
                # post to the action with token, and merchant hash in normal json
                post :update, format: :json , token: merchant_hsh["token"], data: (merchant_hsh)
                # check that provider is updated with the merchant hash info
                updated_provider = Provider.find @provider.id
                updated_provider.send(type_of).should == identifier
            end

        end

    end

    def serialize provider
        provider.serializable_hash only: [:name, :address, :city, :state, :zip, :token, :zinger, :description, :phone]
    end

end