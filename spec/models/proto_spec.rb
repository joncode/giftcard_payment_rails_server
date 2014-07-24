require 'spec_helper'

describe Proto do

    context "Callbacks" do

    	it "should set the value from the shoppingCart" do
    		proto = FactoryGirl.create(:proto, value: nil, shoppingCart: nil)
    		proto.update(shoppingCart:"[{\"detail\":\"The best margherita\",\"price\":13,\"price_promo\":1,\"quantity\":2,\"item_id\":82,\"item_name\":\"Original Margarita\"}]")
    		proto.value.should == "26"
    	end

    	it "should set the cost" do
    		proto = FactoryGirl.create(:proto, cost: nil)
    		proto.update(shoppingCart:"[{\"detail\":\"The best margherita\",\"price\":13,\"price_promo\":1,\"quantity\":2,\"item_id\":82,\"item_name\":\"Original Margarita\"}]")
    		proto.cost.should == "0"
    		proto = FactoryGirl.create(:proto)
    		proto.cost.should == "3"
    	end

    end

	context "Validations" do

		it "requires cat" do
			proto = FactoryGirl.build(:proto, :cat => nil)
			proto.should_not be_valid
			proto.should have_at_least(1).error_on(:cat)
		end

		it "requires expires_at" do
			proto = FactoryGirl.build(:proto, :expires_at => nil)
			proto.should_not be_valid
			proto.should have_at_least(1).error_on(:expires_at)
		end

		it "requires provider_id" do
			proto = FactoryGirl.build(:proto, :provider_id => nil)
			proto.should_not be_valid
			proto.should have_at_least(1).error_on(:provider_id)
		end

		it "requires provider_name" do
			proto = FactoryGirl.build(:proto, :provider_name => nil)
			proto.should_not be_valid
			proto.should have_at_least(1).error_on(:provider_name)
		end

		it "requires giver_id" do
			proto = FactoryGirl.build(:proto, :giver_id => nil)
			proto.should_not be_valid
			proto.should have_at_least(1).error_on(:giver_id)
		end

		it "requires giver_type" do
			proto = FactoryGirl.build(:proto, :giver_type => nil)
			proto.should_not be_valid
			proto.should have_at_least(1).error_on(:giver_type)
		end

		it "requires giver_name" do
			proto = FactoryGirl.build(:proto, :giver_name => nil)
			proto.should_not be_valid
			proto.should have_at_least(1).error_on(:giver_name)
		end

	end

	context "Associations" do

		it "should associate with users" do
			user               = FactoryGirl.create(:user)
			proto              = FactoryGirl.create(:proto)
			proto.users << user
			proto       = Proto.last
			proto.users.should == [user]
			proto.receivables.count.should  == 1
		end

		it "should associate with socials" do
			social                        = FactoryGirl.create(:social)
			proto                         = FactoryGirl.create(:proto)
			proto.socials << social
			proto                  = Proto.last
			proto.socials.should          == [social]
			proto.receivables.count.should == 1
		end

		it "should associate with both users and socials" do
			user                           = FactoryGirl.create(:user)
			social                         = FactoryGirl.create(:social)
			proto                          = FactoryGirl.create(:proto)
			proto.socials << social
			proto.users   << user
			proto                   = Proto.last
			proto.socials.should           == [social]
			proto.users.should             == [user]
			proto.proto_joins.count.should == 2
			proto.receivables.count.should  == 2
		end

		it "should associate with both users and socials" do
			user                           = FactoryGirl.create(:user)
			social                         = FactoryGirl.create(:social)
			proto                          = FactoryGirl.create(:proto)
			proto.socials << social
			proto.users   << user
			proto                   = Proto.last
			proto.socials.should           == [social]
			proto.users.should             == [user]
			proto.proto_joins.count.should == 2
			proto.receivables.count.should  == 2
		end

		it "should associate with gifts as payable and autosave" do
			social                   = FactoryGirl.create(:social)
			proto                    = FactoryGirl.build(:proto)
			proto.socials << social
			proto.id.should be_nil
			gift                     = FactoryGirl.build(:gift)
			gift.payable             = proto
			gift.save
			gift.reload
			gift.payable_id.should   == proto.id
			gift.payable_type.should == proto.class.to_s
			gift.payable.should      == proto
		end

		it "should associate with gifts as proto.gifts" do
			social                   = FactoryGirl.create(:social)
			proto                    = FactoryGirl.build(:proto)
			proto.socials << social
			proto.id.should be_nil
			gift                     = FactoryGirl.build(:gift)
			gift.payable             = proto
			gift.save
			pj = proto.proto_joins.first
			pj.update(gift_id: gift.id)
			proto.gifts.first.should == gift
		end

		it "should associate with giver" do
			social                  = FactoryGirl.create(:social)
			proto                   = FactoryGirl.create(:proto)
			provider                = FactoryGirl.create(:provider)
			proto.giver = provider.biz_user
			proto.socials << social
			proto.save
			proto                   = Proto.last
			proto.giver_id.should   == provider.biz_user.id
			proto.giver_type.should == provider.biz_user.class.to_s
			proto.giver.should      == provider.biz_user
		end

		it "should associate with provider" do
			social                = FactoryGirl.create(:social)
			proto                 = FactoryGirl.create(:proto)
			provider              = FactoryGirl.create(:provider)
			proto.provider_id     = provider.id
			proto.provider_name   = provider.name
			proto.socials << social
			proto.save
			proto                 = Proto.last
			proto.provider.should == provider
		end

	end

	it "builds from factory" do
		proto = FactoryGirl.build :proto
		proto.should be_valid
		proto.save
	end
end
