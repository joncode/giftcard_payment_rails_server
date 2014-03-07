require 'spec_helper'

describe CampaignItem do

    it "builds from factory" do
        cam_item = FactoryGirl.build :campaign_item
        cam_item.should be_valid
    end

    it "should have a shoppingCart" do
        cam_item = FactoryGirl.build :campaign_item
        cam_item.respond_to?(:shoppingCart).should be_true
        cam_item.shoppingCart.should_not be_nil
    end

end