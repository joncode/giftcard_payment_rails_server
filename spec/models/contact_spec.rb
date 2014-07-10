require 'spec_helper'

describe Contact do

	it "builds from factory" do
		contact = FactoryGirl.build :contact
		contact.should be_valid
		contact.save
	end

end
