require 'spec_helper'

describe Web::V2::MerchantsController do

    before(:each) do
        request.env["HTTP_TKN"] = "nj3tOdJOaZa-qFx0FhCLRQ"

        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
    end

    describe "#show" do

        it_should_behave_like("token authenticated", :get, :show, id: 1)

        it "should respond with correct JSON merchant" do
            FactoryGirl.create(:menu_string, provider_id: @provider.id)
            @provider.merchant_id = 10
            @provider.save
            get :show, id: 10, format: :json
            json["data"].class.should == Hash

        end

    end

end