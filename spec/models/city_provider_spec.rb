require 'spec_helper'

describe CityProvider do

    before do
        @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
        @first_provider = FactoryGirl.create(:provider, { name: "amys", city: "New York" })
        @second_provider = FactoryGirl.create(:provider, { name: "bobs", city: "New York" })
        @third_provider = FactoryGirl.create(:provider, { name: "chads", city: "Chicago" })
    end

    it "should create two cityProvider entries" do
    	CityProvider.all.count.should == 2
    end

    it "should have amys and bobs in the New York providers array" do
    	ny_providers = CityProvider.where(city:"New York").first
    	ny_providers.providers_array.should include("amys")
    	ny_providers.providers_array.should include("bobs")
    	ny_providers.providers_array.should_not include("chads")
    end

	it "should have a providers_array and a city" do
		CityProvider.first.providers_array.should_not be_nil
		CityProvider.last.providers_array.should_not be_nil
		CityProvider.first.city.should_not be_nil
		CityProvider.last.city.should_not be_nil
	end

end
# == Schema Information
#
# Table name: city_providers
#
#  id              :integer         not null, primary key
#  city            :string(255)
#  providers_array :text
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

