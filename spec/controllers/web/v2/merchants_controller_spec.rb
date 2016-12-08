require 'spec_helper'

describe Web::V2::MerchantsController do

    before(:each) do
        request.env["HTTP_TKN"] = "nj3tOdJOaZa-qFx0FhCLRQ"

        Merchant.delete_all
        @merchant = FactoryGirl.create(:merchant)
    end

    describe "#show" do

        it_should_behave_like("token authenticated", :get, :show, id: 1)

        it "should respond with correct JSON merchant" do
            FactoryGirl.create(:menu_string, merchant_id: @merchant.id)
            @merchant.save
            get :show, id: 10, format: :json
            json["data"].class.should == Hash

        end

    end

end