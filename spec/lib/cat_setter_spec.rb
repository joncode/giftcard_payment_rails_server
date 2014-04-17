require 'spec_helper'
require 'cat_setter'

def make_all_gifts
        # this creates status agnostic tons
    @start_date = Time.now - 1.month
    @user = FactoryGirl.create :user
    @admin_giver = FactoryGirl.create :admin_user
    @biz_user = FactoryGirl.create :provider
    @provider = @biz_user
    campaign_admin = FactoryGirl.create :campaign, purchaser_type: "AdminGiver"
    campaign_item_admin = FactoryGirl.create :campaign_item, campaign_id: campaign_admin.id
    campaign_merchant = FactoryGirl.create :campaign, purchaser_type: "BizUser"
    campaign_item_merchant = FactoryGirl.create :campaign_item, campaign_id: campaign_merchant.id

    @admin                              = FactoryGirl.create :gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 210
    @admin_regifting_parent              = FactoryGirl.create :gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 100
    @admin_regifted_child               = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @admin_regifting_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 100

    @merchant                           = FactoryGirl.create :gift, giver_type: "BizUser", giver_id: @biz_user.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 200
    @merchant_regifting_parent           = FactoryGirl.create :gift, giver_type: "BizUser", giver_id: @biz_user.id, payable_type: "Debt", status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 100
    @merchant_regifted_child            = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @merchant_regifting_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 100

    @sale                               = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week
    @sale_regifting_parent               = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Sale", status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 100
    @sale_regifted_child                = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @sale_regifting_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 100

    @campaign_admin                     = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_admin.id, payable_type: "CampaignItem", payable_id: campaign_item_admin.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 300
    @campaign_admin_regifting_parent     = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_admin.id, payable_type: "CampaignItem", payable_id: campaign_item_admin.id, status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 100
    @campaign_admin_regifted_child      = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @campaign_admin_regifting_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks

    @campaign_merchant                  = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_merchant.id, payable_type: "CampaignItem", payable_id: campaign_item_merchant.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 300
    @campaign_merchant_regifting_parent  = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_merchant.id, payable_type: "CampaignItem", payable_id: campaign_item_merchant.id, status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 100
    @campaign_merchant_regifted_child   = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @campaign_merchant_regifting_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 100

end

describe "CatSetter" do

    before do
        make_all_gifts
    end

    it "should update the cats for all gifts" do
        CatSetter::perform
        Gift.where(cat: 0).count.should == 0
        Gift.where(cat: 100).count.should == 2
        Gift.where(cat: 101).count.should == 1
        Gift.where(cat: 150).count.should == 2
        Gift.where(cat: 151).count.should == 1
        Gift.where(cat: 200).count.should == 2
        Gift.where(cat: 201).count.should == 1
        Gift.where(cat: 250).count.should == 2
        Gift.where(cat: 251).count.should == 1
        Gift.where(cat: 300).count.should == 2
        Gift.where(cat: 301).count.should == 1
    end

end