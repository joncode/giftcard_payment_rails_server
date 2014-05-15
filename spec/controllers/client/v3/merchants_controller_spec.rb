require 'spec_helper'

describe Client::V3::MerchantsController do

    it "should return the merchant profile and menu" do
        provider = FactoryGirl.create(:provider)
        menu_string = FactoryGirl.create(:menu_string, provider_id: provider.id)
        get :show, id: provider.id, format: :json
        rrc(200)
    end
end