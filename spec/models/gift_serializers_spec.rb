require 'spec_helper'

describe GiftSerializers do

    Gift.delete_all
    User.delete_all
    Provider.delete_all
    @user     = FactoryGirl.create(:user)
    @regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
    @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
    @old_gift = FactoryGirl.create(:gift, giver: @user, receiver: @regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')

    @gift_hsh = {}
    @gift_hsh["message"]        = "I just REGIFTED!"
    @gift_hsh["receiver_name"]  = @receiver.name
    @gift_hsh["receiver_id"]    = @receiver.id
    @gift_hsh["giver"]          = @regifter
    @gift_hsh["old_gift_id"]    = @old_gift.id
    @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    @gift_hsh

    regift = GiftRegift.create @gift_hsh


    [@old_gift, regift].each do |gift|

        it "should serialize" do
            keys = [ "gift_id", "giver","giver_photo" ,"receiver" ,"message","shoppingCart" ,"merchant_name" ,"merchant_address" ,"merchant_phone" ]
            keys << "receiver_photo" if gift.receiver
            hsh  = gift.serialize
            compare_keys hsh, keys
        end

        it "should badge_serialize" do
            keys = ["giver_id", "giver_name", "provider_id", "provider_name", "message", "updated_at", "created_at", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "gift_id"]
            hsh  = gift.badge_serialize
            compare_keys hsh, keys

        end

        it "should giver_serialize" do
            keys = ["created_at", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "value", "updated_at", "shoppingCart", "gift_id", "status", "receiver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address"]
            hsh  = gift.giver_serialize
            compare_keys hsh, keys

        end

        it "should receiver_serialize" do
            keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "shoppingCart", "updated_at", "created_at", "gift_id", "status", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address"]
            hsh  = gift.receiver_serialize
            compare_keys hsh, keys

        end

        it "should admt_serialize" do
            keys = ["gift_id", "provider_id", "name", "merchant_address", "value", "updated_at", "pay_type"]
            hsh  = gift.admt_serialize
            compare_keys hsh, keys

        end

        it "should report_serialize" do
            keys = ["order_num","updated_at","created_at","receiver_name","items","server","value"]
            hsh  = gift.report_serialize
            compare_keys hsh, keys

        end

        it "should promo_serialize" do
            keys = ["value", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items", "expires_at"]
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

