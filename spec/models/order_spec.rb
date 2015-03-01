# require 'spec_helper'

# describe Order do

# 	describe "pos integration" do

# 		before(:each) do
#       		user 		= FactoryGirl.create(:user)
#       		provider 	= FactoryGirl.create(:provider, pos_merchant_id: 1233)
#       		@gift 		= FactoryGirl.create(:gift, receiver_id: user.id, receiver_name: user.name, status: 'open', provider_id: provider.id)
#       		@redeem 	= Redeem.find_or_create_with_gift(@gift)
# 			@pos_params = { "pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @redeem.redeem_code, "server_code" => "john" }
# 		end

#         xit "should not create an order if gift.status is redeemed" do
#         		#this really should never happen because the redeem code is removed from the gift on save
# 			order = Order.init_with_pos(@pos_params, @redeem)
# 			order.save
#         	@gift.reload
#         	@gift.status.should == 'redeemed'
# 			order = Order.init_with_pos(@pos_params, @redeem)
# 			order.save
# 			order.id.should be_nil
# 			order.should have_at_least(1).error_on(:gift)
#         end

#         xit "should not create order if gift.status is expired" do
#         	@gift.update(status: 'expired')
#         	order = Order.init_with_pos(@pos_params, @redeem)
# 			order.save
# 			order.id.should be_nil
# 			order.should have_at_least(1).error_on(:gift)
#         end

#         xit "should create order if gift is notified" do
#         	@gift.reload
#        		order = Order.init_with_pos(@pos_params, @redeem)
# 			order.save
# 			order.id.should_not be_nil
# 			expect(order).to have_at_most(0).error_on(:gift)
#         end

# 		it "should save with pos params" do
# 			rc = @redeem.redeem_code
# 			order = Order.init_with_pos(@pos_params, @redeem)
# 			order.save

# 			order.server_code.should 	 == "john"
# 			order.redeem_code.should 	 == rc
# 			order.ticket_value.should 	 == "13.99"
# 			order.pos_merchant_id.should == 1233
# 		end

# 		it "should return the order object" do
# 			order = Order.init_with_pos(@pos_params, @redeem)
# 			order.class.should == Order
# 		end

# 		it "should raise error if no pos_params" do
# 			expect { Order.init_with_pos(@gift, @redeem, nil) }.to raise_error
# 		end

# 		it "should auto convert ticket_item_ids array of ints" do
# 			@pos_params["ticket_item_ids"] = [ 1245, 17235, 1234 ]
# 			order = Order.init_with_pos(@pos_params, @redeem)
# 			order.save
# 			order.ticket_item_ids.should == [ 1245, 17235, 1234 ]
# 		end

# 	end

# 	describe "Redeem code validation" do

# 		it "should remove redeem code from redeem" do
#       		user 	= FactoryGirl.create(:user)
#       		providr = FactoryGirl.create(:provider, pos_merchant_id: 11111)
#       		gift   	= FactoryGirl.create(:gift, receiver_id: user.id, receiver_name: user.name, provider_id: providr.id)
#       		redeem 	= Redeem.find_or_create_with_gift(gift)
#       		rc     	= redeem.redeem_code
# 			pos_params = { "pos_merchant_id" => 11111, "ticket_value" => "13.99", "redeem_code" => rc, "server_code" => "john" }
# 			order = Order.init_with_pos(pos_params, redeem)
# 			order.save
# 			order.reload
# 			order.redeem_code.should == rc
# 			order.redeem.should 	 == redeem
# 			order.redeem.redeem_code.should  == nil
# 			redeem.reload.redeem_code.should == nil
# 		end

# 	end

# 	describe "#save" do

# 		it "should have a associated gift" do
# 			order = FactoryGirl.create(:order)
# 			gift  = order.gift
# 			order.gift_id.should == gift.id
# 		end

# 		it "should change the gift.status to redeemed" do
# 			order = FactoryGirl.create(:order)
# 			gift  = order.gift
# 			gift.status.should == 'redeemed'
# 		end

# 		it "should set gift.redeemed_at to order.created_at" do
# 			order = FactoryGirl.create(:order)
# 			gift  = order.gift
# 			gift.redeemed_at.should == order.created_at
# 		end

# 		it "should gift.server to server_code" do
# 			order = FactoryGirl.create(:order)
# 			gift  = order.gift
# 			gift.server.should == order.server_code
# 		end

# 		it "should set gift.order_num to order ID abstracted" do
# 			order = FactoryGirl.create(:order)
# 			gift  = order.gift
# 			gift.order_num.should == order.make_order_num
# 		end

# 	end

# 	describe "#save_with_gift_updates" do

# 		it "should have a associated gift on build" do
# 			order = FactoryGirl.build(:order)
# 			gift  = order.gift
# 			order.gift_id.should == gift.id
# 		end

# 		it "should save associated gift with it on save" do
# 			order = FactoryGirl.build(:order)
# 			order.save
# 			gift = Order.last.gift
# 			gift.reload
# 			gift.status.should  		== 'redeemed'
# 			gift.redeemed_at.should 	== order.created_at
# 			gift.server.should  		== order.server_code
# 			gift.order_num.should 		== order.make_order_num
# 		end
# 	end

# 	context "validations & associations" do

# 		it "builds from factory with associations" do
# 			gift = FactoryGirl.create(:gift, status: 'notified', receiver_id: 1)
# 			order = FactoryGirl.create :order, gift_id: gift.id
# 			order.should be_valid
# 			order.should_not be_a_new_record
# 		end

# 		it "adds gift_id if missing" do
# 			order = FactoryGirl.build(:order)
# 			order.gift = nil
# 			order.should be_valid
# 			# order.should have_at_least(1).error_on(:gift_id)
# 		end

# 		it "adds redeem_id if missing" do
# 			order = FactoryGirl.build(:order)
# 			order.redeem = nil
# 			order.should be_valid
# 			# order.should have_at_least(1).error_on(:redeem_id)
# 		end

# 		it "adds provider_id if missing" do
# 			order = FactoryGirl.build(:order)
# 			order.provider = nil
# 			order.should be_valid
# 			# order.should have_at_least(1).error_on(:providr_id)
# 		end

# 		it "validates uniqueness of gift_id" do
# 			previous = FactoryGirl.create(:order)
# 			order    = FactoryGirl.build(:order,  :gift_id => previous.gift_id)
# 			order.should_not be_valid
# 			order.should have_at_least(1).error_on(:gift_id)
# 			#order.errors.full_messages.should include("Validation msg about gift id")
# 		end

# 		it "validates uniqueness of redeem_id" do
# 			previous = FactoryGirl.create(:order)
# 			order = FactoryGirl.build(:order, :redeem_id => previous.redeem_id)
# 			order.should_not be_valid
# 			order.should have_at_least(1).error_on(:redeem_id)
# 			#order.errors.full_messages.should include("Validation msg about redeem id")
# 		end
# 	end
# end



# # adding pos_merchant_id to provider.rb
# # adding pos_merchant_id to redeem.rb
# # + index on [pos_merchant_id , redeem_code]
# # + index on redeem_code
# # adding pos_params to order.rb
# # pos_mechant_id must be stored on the redeem :on_create
# # redeem code uniqueness validation per provider_id

# # wrap the ticket_item_ids in stringified getter/setter or HStore





















# # == Schema Information
# #
# # Table name: orders
# #
# #  id              :integer         not null, primary key
# #  redeem_id       :integer
# #  gift_id         :integer
# #  redeem_code     :string(255)
# #  created_at      :datetime        not null
# #  updated_at      :datetime        not null
# #  server_code     :string(255)
# #  server_id       :integer
# #  provider_id     :integer
# #  employee_id     :integer
# #  pos_merchant_id :integer
# #  ticket_value    :string(255)
# #  ticket_item_ids :string(255)
# #

