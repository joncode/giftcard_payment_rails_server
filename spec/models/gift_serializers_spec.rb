require 'spec_helper'

describe GiftSerializers do
    Gift.delete_all
    User.delete_all
    Provider.delete_all

    ###  making a campaign gift
        provider       = FactoryGirl.create(:provider)
        admin          = FactoryGirl.create(:admin_user)
        giver          = admin.giver
        expiration     = (Time.now + 1.month).to_date
        campaign      = FactoryGirl.create(:campaign, purchaser_type: "#{giver.class}", purchaser_id: giver.id, giver_name: "ItsOnMe Promotional Staff", live_date: (Time.now - 1.week).to_date, close_date: (Time.now + 1.week).to_date, expire_date: (Time.now + 1.week).to_date, budget: 100)
        campaign_item = FactoryGirl.create(:campaign_item, provider_id: provider.id, campaign_id: campaign.id, message: "Enjoy this special gift on us!", expires_at: expiration, shoppingCart: "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]", budget: 100, value: "30")
        gift_hsh_for_campaign = {}
        gift_hsh_for_campaign["receiver_name"]  = "Customer Name"
        gift_hsh_for_campaign["receiver_email"] = "customer@gmail.com"
        gift_hsh_for_campaign["payable_id"]     = campaign_item.id

        campaign_admin_gift = GiftCampaign.create gift_hsh_for_campaign
        
    ###  making a normal gift and regift
        user     = FactoryGirl.create(:user)
        regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
        receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
        old_gift = FactoryGirl.create(:gift, giver: user, receiver: regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')

        gift_hsh_for_regift = {}
        gift_hsh_for_regift["message"]        = "I just REGIFTED!"
        gift_hsh_for_regift["receiver_name"]  = receiver.name
        gift_hsh_for_regift["receiver_id"]    = receiver.id
        gift_hsh_for_regift["giver"]          = regifter
        gift_hsh_for_regift["old_gift_id"]    = old_gift.id
        gift_hsh_for_regift["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
        gift_hsh_for_regift

        regift = GiftRegift.create gift_hsh_for_regift


    #[old_gift, regift, campaign_admin_gift].each do |gift|

    [campaign_admin_gift].each do |gift|
        puts " -------  Test for Cat = #{gift.cat} - Giver type = #{gift.giver_type} - Payable type = #{gift.payable_type} ---------"

        it "should serialize #{gift.cat}" do
            keys = [ "gift_id", "giver","giver_photo" ,"receiver" ,"message","shoppingCart" ,"merchant_name" ,"merchant_address" ,"merchant_phone", "expires_at", "cat" ]
            keys << "receiver_photo" if gift.receiver
            hsh  = gift.serialize
            compare_keys hsh, keys
        end

        it "should badge_serialize #{gift.cat}" do
            keys = ["giver_id", "giver_name", "provider_id", "provider_name", "message", "updated_at", "created_at", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "gift_id", "time_ago", "expires_at", "cat" ]
            hsh  = gift.badge_serialize
            compare_keys hsh, keys

        end

        it "should giver_serialize #{gift.cat}" do
            keys = ["created_at", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "value", "cost", "updated_at", "shoppingCart", "gift_id", "status", "receiver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "time_ago", "expires_at", "cat" ]
            hsh  = gift.giver_serialize
            compare_keys hsh, keys

        end

        it "should receiver_serialize #{gift.cat}" do
            keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "shoppingCart", "updated_at", "created_at", "gift_id", "status", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "time_ago", "expires_at", "cat" ]
            hsh  = gift.receiver_serialize
            compare_keys hsh, keys

        end

        it "should admt_serialize #{gift.cat}" do
            keys = ["gift_id", "provider_id", "name", "merchant_address", "value", "cost", "updated_at", "pay_type", "expires_at", "cat" ]
            hsh  = gift.admt_serialize
            compare_keys hsh, keys

        end

        it "should report_serialize #{gift.cat}" do
            keys = ["order_num","updated_at","created_at","receiver_name","items","server","value", "cost", "expires_at", "cat" ]
            hsh  = gift.report_serialize
            compare_keys hsh, keys

        end

        it "should promo_serialize #{gift.cat}" do
            keys = ["value", "cost", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items", "expires_at", "cat" ]
            keys << "receiver_photo" if gift.receiver
            hsh  = gift.promo_serialize
            compare_keys hsh, keys
        end
    end

    context "status" do

        let(:giver) { FactoryGirl.create(:user, first_name: "Howard", last_name: "Stern", email: "howard@stern.com")}
        let(:provider) { FactoryGirl.create(:provider) }
        let(:gift) { FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: "George Washington", receiver_phone: "8326457787") }

        it "should correctly rep incomplete" do
            gift.receiver_id.should be_nil
            gift.status.should              == 'incomplete'
            gift.giver_status.should        == 'incomplete'
            gift.receiver_status.should     == 'incomplete'
            gift.bar_status.should          == 'live'
            gift.serialize["status"].should           be_nil
            gift.badge_serialize["status"].should     == "incomplete"
            gift.giver_serialize["status"].should     == "incomplete"
            gift.receiver_serialize["status"].should  == "incomplete"
            gift.admt_serialize["status"].should      be_nil
            gift.report_serialize["status"].should    be_nil
            gift.promo_serialize["status"].should     == "incomplete"
        end

        it "should correctly rep open" do
            gift.receiver_id = giver.id
            gift.receiver    = giver
            gift.status = 'open'
            gift.save
            gift.status.should              == 'open'
            gift.giver_status.should        == 'notified'
            gift.receiver_status.should     == 'notified'
            gift.bar_status.should          == 'live'
            gift.serialize["status"].should           be_nil
            gift.badge_serialize["status"].should     == "notified"
            gift.giver_serialize["status"].should     == "notified"
            gift.receiver_serialize["status"].should  == "notified"
            gift.admt_serialize["status"].should      be_nil
            gift.report_serialize["status"].should    be_nil
            gift.promo_serialize["status"].should     == "notified"
        end

        it "should correctly rep notified" do
            gift.receiver_id == giver.id
            gift.update(status: 'notified')
            gift.status.should              == 'notified'
            gift.giver_status.should        == 'notified'
            gift.receiver_status.should     == 'open'
            gift.bar_status.should          == 'live'
            gift.serialize["status"].should           be_nil
            gift.badge_serialize["status"].should     == "open"
            gift.giver_serialize["status"].should     == "notified"
            gift.receiver_serialize["status"].should  == "open"
            gift.admt_serialize["status"].should      be_nil
            gift.report_serialize["status"].should    be_nil
            gift.promo_serialize["status"].should     == "notified"
        end

        it "should correctly rep redeemed" do
            gift.receiver_id == giver.id
            gift.update(status: 'redeemed')
            gift.status.should              == 'redeemed'
            gift.giver_status.should        == 'complete'
            gift.receiver_status.should     == 'redeemed'
            gift.bar_status.should          == 'redeemed'
            gift.serialize["status"].should           be_nil
            gift.badge_serialize["status"].should     == "redeemed"
            gift.giver_serialize["status"].should     == "complete"
            gift.receiver_serialize["status"].should  == "redeemed"
            gift.admt_serialize["status"].should      be_nil
            gift.report_serialize["status"].should    be_nil
            gift.promo_serialize["status"].should     == "complete"
        end

        it "should correctly rep regifted" do
            gift.receiver_id == giver.id
            gift.update(status: 'regifted')
            gift.status.should              == 'regifted'
            gift.giver_status.should        == 'complete'
            gift.receiver_status.should     == 'regifted'
            gift.bar_status.should          == 'regifted'
            gift.serialize["status"].should           be_nil
            gift.badge_serialize["status"].should     == "regifted"
            gift.giver_serialize["status"].should     == "complete"
            gift.receiver_serialize["status"].should  == "regifted"
            gift.admt_serialize["status"].should      be_nil
            gift.report_serialize["status"].should    be_nil
            gift.promo_serialize["status"].should     == "complete"
        end

        it "should correctly rep cancel" do
            gift.update(status: 'cancel')
            gift.status.should              == 'cancel'
            gift.giver_status.should        == 'cancel'
            gift.receiver_status.should     == 'cancel'
            gift.bar_status.should          == 'cancel'
            gift.serialize["status"].should           be_nil
            gift.badge_serialize["status"].should     == "cancel"
            gift.giver_serialize["status"].should     == "cancel"
            gift.receiver_serialize["status"].should  == "cancel"
            gift.admt_serialize["status"].should      be_nil
            gift.report_serialize["status"].should    be_nil
            gift.promo_serialize["status"].should     == "cancel"
        end

        it "should correctly rep expired" do
            gift.update(status: 'expired')
            gift.status.should              == 'expired'
            gift.giver_status.should        == 'expired'
            gift.receiver_status.should     == 'expired'
            gift.bar_status.should          == 'expired'
            gift.serialize["status"].should           be_nil
            gift.badge_serialize["status"].should     == "expired"
            gift.giver_serialize["status"].should     == "expired"
            gift.receiver_serialize["status"].should  == "expired"
            gift.admt_serialize["status"].should      be_nil
            gift.report_serialize["status"].should    be_nil
            gift.promo_serialize["status"].should     == "expired"
        end

    end
end

