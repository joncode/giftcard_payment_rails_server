require 'spec_helper'

include CampaignFactory
include LandingPageFactory

describe GiftAffiliate do

	describe "create" do

	    before(:each) do
	    	campaign, campaign_item, provider, affiliate, landing_page = affiliate_campaign
	        @gift_hsh = { "link" => landing_page.link, "c_item_id" => campaign_item.id, "rec_net" => "em", "rec_net_id" => "testy34@gmails.com" }
	    end

        it_should_behave_like "gift serializer" do
            let(:object) { GiftAffiliate.create(@gift_hsh) }
        end

        it_should_behave_like "gift status" do
            let(:object) { GiftAffiliate.create(@gift_hsh) }
            let(:cat)    { 150 }
        end

		it "should accept link, rec_net, rec_net_id, and c_item_id and make a gift" do
			gift = GiftAffiliate.create(@gift_hsh)
			gift.receiver_email.should == @gift_hsh["rec_net_id"]
			gift.receiver_id.should be_nil
		end

		it "should not send 2 gifts per campaing to a rec_net_id" do
			gift = GiftAffiliate.create(@gift_hsh)
			gift2 = GiftAffiliate.create(@gift_hsh)
			gift2.class.should == String
		end
	end
end