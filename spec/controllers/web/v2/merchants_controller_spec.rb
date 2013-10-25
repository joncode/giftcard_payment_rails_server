require 'spec_helper'

describe Web::V2::MerchantsController do

    before(:each) do
        request.env["HTTP_TKN"] = "nj3tOdJOaZa-qFx0FhCLRQ"

        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
    end

    describe "#show" do

        it "should not allow unauthenticated access" do
            request.env["HTTP_TKN"] = "No_Entrance"
            get :show, id: 1, format: :json
            response.response_code.should == 401
        end

        it "should respond with correct JSON merchant" do
            get :show, id: @provider.id, format: :json
            json["data"].class.should == Hash
        end

    end

end