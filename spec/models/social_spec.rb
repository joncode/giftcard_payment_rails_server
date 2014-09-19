require 'spec_helper'

describe Social do

	it "builds from factory" do
		social = FactoryGirl.build :social
		social.should be_valid
		social.save
	end



	it "require network" do
		social = FactoryGirl.build(:social, :network => nil)
		social.should_not be_valid
		social.should have_at_least(1).error_on(:network)
	end

	it "requires network_id" do
		social = FactoryGirl.build(:social, :network_id => nil)
		social.should_not be_valid
		social.should have_at_least(1).error_on(:network_id)
	end

	it "has_many :protos :through :proto_joins" do
		proto_1 = FactoryGirl.create :proto
		proto_2 = FactoryGirl.create :proto
		social = FactoryGirl.create :social
		pj1 = FactoryGirl.create :proto_join, proto_id: proto_1.id,
											  receivable_id: social.id,
											  receivable_type: "Social"
		pj2 = FactoryGirl.create :proto_join, proto_id: proto_2.id,
											  receivable_id: social.id,
											  receivable_type: "Social"
		social.protos.count.should == 2
		social.proto_joins.count.should == 2
	end

	it "should reduce phone to digits only" do
		social = Social.new(network: 'phone', network_id: '(718) 232- 7584')
		social.save
		social.network_id.should == "7182327584"
	end

	it "should downcase emails" do
		social = Social.new(network: 'email', network_id: 'JONG@gmAIL.cOM')
		social.save
		social.network_id.should == "jong@gmail.com"
	end

	it "should reject incorrectly formatted emails" do
		social = Social.new(network: 'email', network_id: 'J@NG@gmAIL.cOM')
		social.save
		social.errors.full_messages.should == ["Network is invalid"]
	end

	it "should enforce network + network_id uniqueness validation" do
		Social.create(network: "facebook", network_id: "782364192834")
		Social.create(network: "facebook", network_id: "782364192834")

		socials = Social.all
		socials.count.should == 1
	end

    context "Associations" do
        it "should have many providers_socials" do
            social    = FactoryGirl.create :social
            provider1 = FactoryGirl.create :provider
            provider2 = FactoryGirl.create :provider
            FactoryGirl.create :providers_social, provider_id: provider1.id, social_id: social.id
            FactoryGirl.create :providers_social, provider_id: provider2.id, social_id: social.id
            social.providers_socials.count.should == 2
            social.providers.count.should == 2
        end
        it "should have many at_users_socials" do
            social    = FactoryGirl.create :social
            at_user1 = FactoryGirl.create :at_user
            at_user2 = FactoryGirl.create :at_user
            FactoryGirl.create :at_users_social, at_user_id: at_user1.id, social_id: social.id
            FactoryGirl.create :at_users_social, at_user_id: at_user2.id, social_id: social.id
            social.at_users_socials.count.should == 2
        end
    end

end
