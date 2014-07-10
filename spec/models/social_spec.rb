require 'spec_helper'

describe Social do

	it "builds from factory" do
		social = FactoryGirl.build :social
		social.should be_valid
		social.save
	end

end
