require 'spec_helper'

describe GiftCampaign do

    before(:each) do
        Provider.delete_all
        @provider      = FactoryGirl.create(:provider)
        @admin         = FactoryGirl.create(:admin_user)
        @admin_giver   = AdminGiver.find(@admin.id)
        @expiration    = (Time.now + 1.month).to_date
        @campaign_item = FactoryGirl.create(:campaign_item, provider_id: @provider.id,
                                                            reserve: 50,
                                                            giver_type: "AdminGiver",
                                                            giver_name: "ItsOnMe Promotional Staff",
                                                            giver_id: @admin.id,
                                                            owner_type: "AdminGiver",
                                                            owner_id: @admin.id,
                                                            message: "Enjoy this special gift on us!",
                                                            expires_at: @expiration,
                                                            shoppingCart: "[{\"price\":\"10\",\"price\":\"8\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                            value: "30",
                                                            cost: "24")
        @gift_hsh = {}
        @gift_hsh["receiver_name"]  = "Customer Name"
        @gift_hsh["receiver_email"] = "customer@gmail.com"
        @gift_hsh["payable_id"]     = @campaign_item.id
    end

    it "should create gift" do
        gift_campaign = GiftCampaign.create(@gift_hsh)
        gift_campaign.class.should          == GiftCampaign
        gift_campaign.message.should        == @gift_hsh["message"]
        gift_campaign.receiver_name.should  == "Customer Name"
        gift_campaign.receiver_email.should == "customer@gmail.com"
        gift_campaign.provider_id.should    == @provider.id
        gift_campaign.provider_name.should  == @provider.name
        gift_campaign.giver_type.should     == "AdminGiver"
        gift_campaign.giver_id.should       == @admin.id
        gift_campaign.giver_name.should     == "ItsOnMe Promotional Staff"
        gift = Gift.find(gift_campaign.id)
        gift.class.should          == Gift
        gift.message.should        == @gift_hsh["message"]
        gift.receiver_name.should  == "Customer Name"
        gift.receiver_email.should == "customer@gmail.com"
        gift.provider_id.should    == @provider.id
        gift.provider_name.should  == @provider.name
        gift.giver_type.should     == "AdminGiver"
        gift.giver_id.should       == @admin.id
        gift.giver_name.should     == "ItsOnMe Promotional Staff"
    end

    it "should associate the CampaignItem as the payable" do
        gift = GiftCampaign.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.cost.should            == "24"
        gift.payable.owner.should   == @admin_giver
        gift.payable.amount.should  == "24"
    end


    # Value/Cost are currently calculated ONLY in AT
    xit "should set the cost based of the promo prices correctly" do
        @campaign_item.update(shoppingCart: [{"price"=>"4", "price_promo"=>"1.23", "quantity"=>2, "section"=>"Beer", "item_id"=>543, "item_name"=>"Corona"}].to_json)
        gift = GiftCampaign.create @gift_hsh
        gift.reload
        gift.cost.should            == "2.46"
    end

    # check that the campaign has gifts to give
    it "should not create gift if there is no reserve" do
        @campaign_item.update(reserve: 0)
        gift = GiftCampaign.create @gift_hsh
        gift.errors.count.should            == 1
        gift.errors.full_messages[0].should == "Payable reserve is empty. No more gifts can be created under this campaign item."
    end



        # associate the gift with the campaign item
        # set the giver based on the campaign item
        # create a payable that associates with the campaign => payable now IS the campaign item
        # set the receiver name if the receiver is not in our database
        #     setting the receiver name to campaign name and then letting PeopleFinder in gift model overwrite receiver_name

end