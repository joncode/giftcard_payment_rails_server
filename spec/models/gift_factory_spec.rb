# require 'spec_helper'

# describe GiftFactory do

#     context "with receiver obj" do

#             # open # unpaid

#         before(:all) do
#             gift_params = gift_w_receiver
#             @gift       = GiftFactory.new(gift_params)
#         end

#         describe :new do

#             it "should set the statuses" do
#                 @gift.purchaser_status.should        == 'notified'
#                 @gift.receiver_status.should         == 'notified'
#                 @gift.bar_status.should              == 'live'
#                 @gift.merchant_acct_status.should    be_nil
#                 @gift.admin_status.should            == 'notified'
#             end

#             it "should determine the money flow" do

#                 @gift.total_charge.should        == "44.1"
#                 @gift.db_revenue.should          == "44.1"
#                 @gift.merchant_revenue.should    == "0"
#             end

#             it "should know its scopes" do
#                 @gift.receiver_gift_center?.should   == false
#                 @gift.purchasor_archive?.should      == false
#                 @gift.merchant_orders?.should        == false
#                 @gift.merchant_reports?.should       == false
#                 @gift.admin_tools?.should            == true
#             end

#             it "should know its controller response" do
#                 @gift.controller_response.should be_nil
#             end
#         end

#     end

#    context "without receiver obj" do

#             # incomplete # unpaid

#         before(:all) do
#             gift_params = gift_wo_receiver
#             @gift       = GiftFactory.new(gift_params)
#         end

#         describe :new do

#             it "should set the statuses" do
#                 @gift.purchaser_status.should        == 'incomplete'
#                 @gift.receiver_status.should         == 'incomplete'
#                 @gift.bar_status.should              == 'live'
#                 @gift.merchant_acct_status.should    be_nil
#                 @gift.admin_status.should            == 'incomplete'
#             end

#             it "should determine the money flow" do

#                 @gift.total_charge.should        == "44.1"
#                 @gift.db_revenue.should          == "44.1"
#                 @gift.merchant_revenue.should    == "0"
#             end

#             it "should know its scopes" do
#                 @gift.receiver_gift_center?.should   == false
#                 @gift.purchasor_archive?.should      == false
#                 @gift.merchant_orders?.should        == false
#                 @gift.merchant_reports?.should       == false
#                 @gift.admin_tools?.should            == true
#             end

#             it "should know its controller response" do
#                 @gift.controller_response.should be_nil
#             end
#         end

#         describe :receiver= do

#             it "should set the statuses" do
#                 @gift.purchaser_status.should        == 'notified'
#                 @gift.receiver_status.should         == 'notified'
#                 @gift.bar_status.should              == 'live'
#                 @gift.merchant_acct_status.should    be_nil
#                 @gift.admin_status.should            == 'notified'
#             end

#             it "should determine the money flow" do

#                 @gift.total_charge.should        == "44.1"
#                 @gift.db_revenue.should          == "44.1"
#                 @gift.merchant_revenue.should    == "0"
#             end

#             it "should know its scopes" do
#                 @gift.receiver_gift_center?.should   == false
#                 @gift.purchasor_archive?.should      == false
#                 @gift.merchant_orders?.should        == false
#                 @gift.merchant_reports?.should       == false
#                 @gift.admin_tools?.should            == true
#             end

#             it "should know its controller response" do
#                 @gift.controller_response.should be_nil
#             end
#         end

#     end

#     describe :receiver_opened do

#     end

#     describe :redeemed do

#     end

#     describe :regifted_to do

#     end

#     describe :combined do

#     end

#     describe :settled do

#     end

#     describe :cancel do

#     end

#     describe :paid_with_payable do

#     end

#     describe :void_with_payable do

#     end

#     describe :refund_with_payable do

#     end

#     describe :refund_cancel_with_payable do

#     end

#     def gift_w_receiver
#         {"receiver_name"=>"Joe Meeks", "giver_id"=>"65", "giver_name"=>"Joe Meeks", "total"=>42, "service"=>2.1, "message"=>"test the map", "credit_card"=>141, "provider_id"=>72, "provider_name"=>"Mon Ami Gabi", "receiver_id"=>"65", "receiver_phone"=>"7024109601", "receiver_email"=>"joe.meeks@sos.me", "twitter"=>"898503566", "facebook_id"=>"1617770036", "shoppingCart" => shoppingCart}
#     end

#     def gift_wo_receiver
#         {"receiver_name"=>"Joe Meeks", "giver_id"=>"65", "giver_name"=>"Joe Meeks", "total"=>42, "service"=>2.1, "message"=>"test the map", "credit_card"=>141, "provider_id"=>72, "provider_name"=>"Mon Ami Gabi", "receiver_phone"=>"7024109601", "receiver_email"=>"joe.meeks@sos.me", "twitter"=>"898503566", "facebook_id"=>"1617770036", "shoppingCart" => shoppingCart}
#     end

#     def shoppingCart
#          [{"item_id"=>176, "item_name"=>"Baked Goat Cheese", "price"=>"11", "quantity"=>2}, {"item_id"=>177, "item_name"=>"Bordeux Chateau Cadillac", "price"=>"10", "quantity"=>2}]
#     end


# end