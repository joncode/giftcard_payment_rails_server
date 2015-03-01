require 'spec_helper'

include AffiliateFactory

describe LandingPage do

	describe "click" do

		it "should create a landing_page record if none exist with that link and make click = 1" do
			prev_lp = LandingPage.where(link: "itson.me/uniqueness123")
			prev_lp.count.should == 0
			lp = LandingPage.click(link: "itson.me/uniqueness123")
			lp.persisted?.should be_true
			lp.link.should == "itson.me/uniqueness123"
			lp.clicks.should == 1
		end

		it "should assign the affiliate_id to the newly created landing_page" do
			aa = make_affiliate("Afff", "One")
			aa.update(url_name: "tester_one")
			prev_lp = LandingPage.where(link: "itson.me/shop/san-diego?aid=tester_one")
			prev_lp.count.should == 0
			lp = LandingPage.click(link: "itson.me/shop/san-diego?aid=tester_one")
			lp.affiliate.should == aa
		end

		it "should fail with error messages" do
			aa = make_affiliate("Afff", "One")
			aa.update(url_name: "tester_one")
			prev_lp = LandingPage.where(link: "itson.me/shop/san-diego?aid=tester_one")
			prev_lp.count.should == 0
			lp = LandingPage.click(link: "itson.me/shop/san-diego?aitester_one")
			lp.errors.messages.inspect
			lp.affiliate.should be_nil
			lp.id.should_not be_nil
		end

		it "should increment click of link landing_page that already exist" do
			prev_lp = FactoryGirl.create(:landing_page, link: "itson.me/uniqueness123", clicks: 23)
			prev_lp.persisted?.should be_true
			lp = LandingPage.click(link: "itson.me/uniqueness123")
			lp.persisted?.should be_true
			lp.link.should == "itson.me/uniqueness123"
			lp.clicks.should == 24
		end

	end

	it "should enforce uniqueness on :link" do
		lp = FactoryGirl.create(:landing_page, link: "itson.me/uniqueness123")
		lp2 = FactoryGirl.build(:landing_page, link: "itson.me/uniqueness123")
		lp2.should have_at_least(1).error_on(:link)
	end

    it 'builds from factory' do
        lp = FactoryGirl.build :landing_page
        lp.should be_valid
    end

end
# == Schema Information
#
# Table name: landing_pages
#
#  id                :integer         not null, primary key
#  campaign_id       :integer
#  affiliate_id      :integer
#  title             :string(255)
#  banner_photo_url  :string(255)
#  example_item_id   :integer
#  page_json         :json
#  sponsor_photo_url :string(255)
#  link              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  clicks            :integer         default(0)
#  users             :integer         default(0)
#  gifts             :integer         default(0)
#

