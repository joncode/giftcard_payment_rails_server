require 'spec_helper'
require 'cancel_duplicate_gifts'


describe "Should cancel duplicates" do
    before(:each) do
        User.any_instance.stub(:init_confirm_email).and_return(true)
    end

	before do
		Gift.delete_all
		@provider1 = FactoryGirl.create :merchant
		provider2 = FactoryGirl.create :merchant
		10.times do
			FactoryGirl.create :gift, receiver_email: "ann@email.com", merchant_id: @provider1.id, receiver_id: nil
		end
		10.times do
			FactoryGirl.create :gift, receiver_email: "ann@email.com", merchant_id: provider2.id, receiver_id: nil
		end
		15.times do
			FactoryGirl.create :gift, receiver_email: "bob@email.com", merchant_id: @provider1.id, receiver_id: nil
		end
		15.times do
			gift = FactoryGirl.create :gift, receiver_email: "bob@email.com", merchant_id: @provider1.id, receiver_id: nil
			gift.update(created_at: 1.month.ago)
		end
		20.times do
			FactoryGirl.create :gift, receiver_email: "cam@email.com", merchant_id: @provider1.id, receiver_id: nil
		end
		20.times do
			FactoryGirl.create :gift, receiver_email: "cam@email.com", merchant_id: @provider1.id, receiver_id: 1
		end
		FactoryGirl.create :gift, receiver_email: "dan@email.com", merchant_id: @provider1.id, receiver_id: nil
	end

	it "should find the duplicate gifts" do
		CancelDuplicateGifts.find_duplicates(@provider1.id, 1.day.ago)
	end

	it "should update the correct gifts" do
		CancelDuplicateGifts.perform(@provider1.id, 1.day.ago)
		Gift.count.should == 91
		scoped_gifts = Gift.where(merchant_id: @provider1.id, receiver_id: nil).where("created_at > ?", 1.week.ago)
		scoped_gifts.count.should == 46
		scoped_gifts.where(status: "cancel", pay_stat: "payment_error").count.should == 42
		scoped_gifts.where(receiver_email: "ann@email.com").where.not(status: "cancel").count.should == 1
		scoped_gifts.where(receiver_email: "bob@email.com").where.not(status: "cancel").count.should == 1
		scoped_gifts.where(receiver_email: "cam@email.com").where.not(status: "cancel").count.should == 1
		scoped_gifts.where(receiver_email: "dan@email.com").where.not(status: "cancel").count.should == 1
	end
end

describe "undo all cancels" do
    before(:each) do
        User.any_instance.stub(:init_confirm_email).and_return(true)
    end
	it "should undo dual cancelled gifts" do
		Gift.delete_all
		@provider1 = FactoryGirl.create :provider
		10.times do
			gift = FactoryGirl.create :gift, receiver_email: "ann@email.com", merchant_id: @provider1.id, receiver_id: nil
			gift.update(status: "cancel")
		end
		10.times do
			FactoryGirl.create :gift, receiver_email: "bob@email.com", merchant_id: @provider1.id, receiver_id: nil, status: "incomplete"
		end
		10.times do
			gift = FactoryGirl.create :gift, receiver_email: "cam@email.com", merchant_id: @provider1.id, receiver_id: nil
			gift.update(status: "cancel")
		end
		CancelDuplicateGifts.undo_dual_cancels(@provider1.id, 1.day.ago)
		Gift.count.should == 30
		Gift.where(status: "incomplete").count.should == 12

	end

end