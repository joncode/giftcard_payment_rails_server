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
end# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#  origin         :string(255)
#

