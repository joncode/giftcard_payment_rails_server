require 'spec_helper'

describe "Broken Tests" do
	before do
		@last_update = "6/23/14"
		@broken_tests = [
"spec/support/payable_ducktype_spec.rb",
"spec/features/connections_spec.rb",
"spec/features/end_to_end_spec.rb",
"spec/lib/tasks/reconcile_emails_spec.rb",
"spec/models/email_spec.rb",
"spec/controllers/client/v3/gifts_controller_spec.rb:25 # Client::V3::GiftsController index should serialize the gifts with defined keys",
"spec/controllers/mdot/v2/facebook_controller_spec.rb:101 # Mdot::V2::FacebookController create should return 407 Proxy Authentication Required when Oauth keys have expired",
"spec/controllers/mdot/v2/twitter_controller_spec.rb:104 # Mdot::V2::TwitterController create should return 407 Proxy Authentication Required when Oauth keys have expired",
"spec/models/gift_admin_spec.rb:183 # GiftAdmin messaging should not message users when payment_error",
"spec/models/gift_campaign_spec.rb:251 # GiftCampaign Merchant Campaign messaging should not message users when payment_error",
"spec/models/gift_promo_spec.rb:177 # GiftPromo messaging should not message users when payment_error",
"spec/models/user_spec.rb:685 # User friend maker should call relationships when user is created -- ADDED 6/23",
"spec/models/user_spec.rb:693 # User friend maker should call relationships when user socials are updated -- ADDED 6/23"
		]
	end
	it "should have zero broken tests" do
		if @broken_tests.count > 0
			puts "===================================================="
			puts "========== #{@broken_tests.count} Broken Tests as of #{@last_update} ==========="
			puts "===================================================="
			@broken_tests.each do |test|
				puts test
			end
			puts "===================================================="
			puts "=============== End of Broken Tests================="
			puts "===================================================="
		end
		@broken_tests.count.should == 0
	end
end
