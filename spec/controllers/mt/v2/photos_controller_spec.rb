require 'spec_helper'

describe Mt::V2::PhotosController do

    before(:each) do
        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
    end

    describe "#update" do

        context "authorization" do

            xit "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :update, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        xit "should update photo" do
            provider = FactoryGirl.create(:provider)
            request.env["HTTP_TKN"] = provider.token
            put :update, id: provider.id, format: :json, data: { "image" => "helpful_new_image.png"}
            provider = Provider.find(provider.id)
            provider.get_photo.should == "helpful_new_image.png"
        end

    end


end