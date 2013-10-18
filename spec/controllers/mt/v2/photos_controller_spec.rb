require 'spec_helper'

describe Mt::V2::PhotosController do

    before(:each) do
        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
    end

    describe "#update" do

        xit "should update photo" do
            provider = FactoryGirl.create(:provider)
            request.env["HTTP_TKN"] = provider.token
            put :update, id: provider.id, format: :json, data: { "image" => "helpful_new_image.png"}
            provider = Provider.find(provider.id)
            provider.get_photo.should == "helpful_new_image.png"
        end

    end


end