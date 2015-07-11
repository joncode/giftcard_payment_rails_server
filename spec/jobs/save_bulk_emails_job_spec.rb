require 'spec_helper'

describe SaveBulkEmailsJob do

	before(:each) do
		Social.delete_all
		ProvidersSocial.delete_all
		ProtoJoin.delete_all
		@provider = FactoryGirl.create(:merchant)
	end

	describe :save do

		it "should create the providers_socials" do
			merchant =  FactoryGirl.create(:merchant)
			proto    = FactoryGirl.create(:proto, merchant_id: merchant.id)

			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bob@email.com\",\"cam@email.com\"]",
				proto_id: proto.id,
				merchant_id: merchant.id
			SaveBulkEmailsJob.perform(bulk_email.id)
			ProvidersSocial.count.should == 3
			ProtoJoin.count.should == 3
		end

		it "should create the providers_social but only once" do
			merchant =  FactoryGirl.create(:merchant)
			proto    = FactoryGirl.create(:proto, merchant_id: merchant.id)
			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bob@email.com\",\"cam@email.com\"]",
				proto_id: proto.id,
				merchant_id: merchant.id
			SaveBulkEmailsJob.perform(bulk_email.id)
			s = Social.all
			s.count.should == 3
			providers_socials = ProvidersSocial.where(merchant_id: merchant.id)
			# binding.pry
			providers_socials.count.should == 3

			bulk_email2 = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bob@email.com\",\"cam@email.com\"]",
				proto_id: proto.id,
				merchant_id: merchant.id
			SaveBulkEmailsJob.perform(bulk_email2.id)
			s = Social.all
			s.count.should == 3
			providers_socials = ProvidersSocial.where(merchant_id: merchant.id)
			providers_socials.count.should == 3
		end

		it "should not create multiple Socials for same network and network_id" do
			merchant =  FactoryGirl.create(:merchant)
			proto    = FactoryGirl.create(:proto, merchant_id: merchant.id)

			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"ann@email.com\",\"cam@email.com\"]",
				proto_id: proto.id,
				merchant_id: merchant.id
			SaveBulkEmailsJob.perform(bulk_email.id)
			ProvidersSocial.count.should == 2
			ProtoJoin.count.should == 2
		end

		it "should reject bad contacts and save good contacts" do
			merchant =  FactoryGirl.create(:merchant)
			proto    = FactoryGirl.create(:proto, merchant_id: merchant.id)

			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bobatemail.com\",\"cam@emailcom\"]",
				proto_id: proto.id,
				merchant_id: merchant.id
			SaveBulkEmailsJob.perform(bulk_email.id)
			Social.count.should == 1
			ProvidersSocial.count.should == 1
			ProtoJoin.count.should == 1
		end

		it "should save the emails as socials without making proto joins" do
			merchant =  FactoryGirl.create(:merchant)

			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bob@email.com\",\"cam@email.com\"]",
				proto_id: nil,
				merchant_id: merchant.id
			SaveBulkEmailsJob.perform(bulk_email.id)
			Social.count.should == 3
			ProvidersSocial.count.should == 3
			ProtoJoin.count.should == 0
		end

		it "should save the emails as socials AND create the proto join" do

			merchant =  FactoryGirl.create(:merchant)
			proto    = FactoryGirl.create(:proto, merchant_id: merchant.id)

			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bob@email.com\",\"cam@email.com\"]",
				proto_id: proto.id,
				merchant_id: merchant.id
			SaveBulkEmailsJob.perform(bulk_email.id)
			Social.count.should == 3
			ProvidersSocial.count.should == 3
			ProtoJoin.count.should == 3
		end

		it "should not create proto joins when one exists without a gift id" do
			proto = FactoryGirl.create(:proto)
			["bob@email.com", "cam@email.com", "ann@email.com"].each do |email|
				soci = Social.create(network: 'email', network_id: email)
				ProtoJoin.create(proto_id: proto.id, receivable_id: soci.id, receivable_type: 'Social', gift_id: nil)
			end
			socials = Social.all
			socials.count.should == 3
			socials.each do |soc|
				soc.proto_joins.count.should == 1
			end

			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bob@email.com\",\"cam@email.com\"]",
				proto_id: proto.id

			SaveBulkEmailsJob.perform(bulk_email.id)
			socials = Social.all
			socials.count.should == 3
			socials.each do |soc|
				soc.proto_joins.count.should == 1
			end
		end

		it "should create proto joins when one exists with a gift id" do
			proto = FactoryGirl.create(:proto)
			["bob@email.com", "cam@email.com", "ann@email.com"].each_with_index do |email,index|
				soci = Social.create(network: 'email', network_id: email)
				ProtoJoin.create(proto_id: proto.id, receivable_id: soci.id, receivable_type: 'Social', gift_id: index + 1)
			end
			socials = Social.all
			socials.count.should == 3
			socials.each do |soc|
				soc.proto_joins.count.should == 1
			end

			bulk_email = FactoryGirl.create :bulk_email,
				data: "[\"ann@email.com\",\"bob@email.com\",\"cam@email.com\"]",
				proto_id: proto.id

			SaveBulkEmailsJob.perform(bulk_email.id)
			socials = Social.all
			socials.count.should == 3
			socials.each do |soc|
				soc.proto_joins.count.should == 2
			end
		end

	end

end