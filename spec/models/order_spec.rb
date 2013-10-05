require 'spec_helper'


describe Order do

		it "builds from factory with associations" do
			order = FactoryGirl.create :order
			order.should be_valid
			order.should_not be_a_new_record
		end

		it "adds gift_id if missing" do
			order = FactoryGirl.build(:order)
			order.gift = nil
			order.should be_valid
			# order.should have_at_least(1).error_on(:gift_id)
		end

		it "adds redeem_id if missing" do
			order = FactoryGirl.build(:order)
			order.redeem = nil
			order.should be_valid
			# order.should have_at_least(1).error_on(:redeem_id)
		end

		it "adds provider_id if missing" do
			order = FactoryGirl.build(:order)
			order.provider = nil
			order.should be_valid
			# order.should have_at_least(1).error_on(:provider_id)
		end

		it "validates uniqueness of gift_id" do
			previous = FactoryGirl.create(:order)
			order    = FactoryGirl.build(:order,  :gift_id => previous.gift_id)
			order.should_not be_valid
			order.should have_at_least(1).error_on(:gift_id)
			#order.errors.full_messages.should include("Validation msg about gift id")
		end

		it "validates uniqueness of redeem_id" do
			previous = FactoryGirl.create(:order)
			order = FactoryGirl.build(:order, :redeem_id => previous.redeem_id)
			order.should_not be_valid
			order.should have_at_least(1).error_on(:redeem_id)
			#order.errors.full_messages.should include("Validation msg about redeem id")
		end

		describe "#save" do

			it "should have a associated gift" do
				order = FactoryGirl.create(:order)
				gift  = order.gift
				order.gift_id.should == gift.id
			end

			it "should change the gift.status to redeemed" do
				order = FactoryGirl.create(:order)
				gift  = order.gift
				gift.status.should == 'redeemed'
			end

			it "should set gift.redeemed_at to order.created_at" do
				order = FactoryGirl.create(:order)
				gift  = order.gift
				gift.redeemed_at.should == order.created_at
			end

			it "should gift.server to server_code" do
				order = FactoryGirl.create(:order)
				gift  = order.gift
				gift.server.should == order.server_code
			end

			it "should set gift.order_num to order ID abstracted" do
				order = FactoryGirl.create(:order)
				gift  = order.gift
				gift.order_num.should == order.make_order_num
			end

		end

		describe "#save_with_gift_updates" do

			it "should have a associated gift on build" do
				order = FactoryGirl.build(:order)
				gift  = order.gift
				order.gift_id.should == gift.id
			end

			it "should save associated gift with it on save" do
				order = FactoryGirl.build(:order)
				order.save
				gift = Order.last.gift
				gift.status.should  		== 'redeemed'
				gift.redeemed_at.should 	== order.created_at
				gift.server.should  		== order.server_code
				gift.order_num.should 		== order.make_order_num
			end
		end
end



	# validates :gift_id   , presence: true, uniqueness: true
	# validates :redeem_id , presence: true, uniqueness: true
