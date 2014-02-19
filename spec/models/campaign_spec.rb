require 'spec_helper'

describe Campaign do

    it "builds from factory" do
        campaign  = FactoryGirl.create :campaign
        admin_giver = campaign.giver
        admin_giver.should be_valid
    end

    it "should get ID from :campaign" do
        campaign  = FactoryGirl.create :campaign
        admin_giver = campaign.giver
        admin_giver.id.should == campaign.id
    end

    it "should respond to name with '#{SERVICE_NAME} Staff'" do
        campaign  = FactoryGirl.create :campaign
        admin_giver = campaign.giver
        admin_giver.name.should == "#{SERVICE_NAME} Staff"
    end

    it "should respond to get_photo with cloud logo URL" do
        campaign  = FactoryGirl.create :campaign
        admin_giver = campaign.giver
        admin_giver.get_photo.should == "http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
    end

    it "should associate with gift as giver" do
        provider    = FactoryGirl.create(:provider)
        campaign  = FactoryGirl.create :campaign
        admin_giver = campaign.giver
        gift        = FactoryGirl.build(:gift)
        gift.giver  = admin_giver
        gift.save

        admin_giver.sent.first.id.should          == gift.id
        admin_giver.sent.first.class.should       == Gift
        admin_giver.sent.first.giver_name.should  == "#{SERVICE_NAME} Staff"
    end

    it "should associate with Debts" do
        campaign  = FactoryGirl.create :campaign
        admin_giver = campaign.giver
        debt = FactoryGirl.create(:debt, owner: admin_giver)
        admin_giver.debts.first.class.should == Debt
        admin_giver.debts.where(id: debt.id).count.should == 1
    end

    it "should create debt with cart total" do
        campaign  = FactoryGirl.create :campaign
        admin_giver = campaign.giver
        debt = admin_giver.incur_debt("100.00")
        debt.amount.to_f.should == 100.0
        debt = admin_giver.incur_debt("131")
        debt.amount.to_f.should == 131.0
    end
end

