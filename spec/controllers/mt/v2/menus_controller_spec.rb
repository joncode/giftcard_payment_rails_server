require 'spec_helper'

describe Mt::V2::MenusController do

    before(:each) do
        request.env["HTTP_TKN"] = "nj3tOdJOaZa-qFx0FhCLRQ"

        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
    end

    describe "#update" do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :update, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        pending "nested tests needed"
    end

end