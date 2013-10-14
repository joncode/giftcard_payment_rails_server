require 'spec_helper'

describe Web::V2::MerchantsController do

    describe "#show" do

        before(:all) do
            Provider.delete_all
            @provider = FactoryGirl.create(:provider)
        end

        it "should return 401 unauthorized if www token not submitted in header" do
            get :show, id: @provider.id, format: :json
            response.status.should == 401
        end

        it "should be a GET route" do
            post :show, id: @provider.id, format: :json
            response.status.should == 200
        end

        it "should respond with correct JSON merchant" do
            get :show, id: @provider.id, format: :json
            json["data"].class.should == Hash
        end

    end

end