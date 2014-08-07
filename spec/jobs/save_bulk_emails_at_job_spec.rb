require 'spec_helper'

describe SaveBulkEmailsAtJob do

	it "should create at_user_social" do
		at_user    = FactoryGirl.create :admin_user
		proto      = FactoryGirl.create :proto
		bulk_email = FactoryGirl.create :bulk_email, at_user_id: at_user.id, proto_id: proto.id

		SaveBulkEmailsAtJob.perform(bulk_email.id)
		Social.count.should == 3
	end
	
end