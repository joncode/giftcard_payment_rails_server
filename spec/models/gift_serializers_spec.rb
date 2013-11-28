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
            keys = ["created_at", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "total", "updated_at", "shoppingCart", "gift_id", "status", "receiver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address"]
            hsh  = gift.giver_serialize
            compare_keys hsh, keys

        end

        it "should receiver_serialize" do
            keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "shoppingCart", "updated_at", "created_at", "gift_id", "status", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address"]
            hsh  = gift.receiver_serialize
            compare_keys hsh, keys

        end

        it "should admt_serialize" do
            keys = ["gift_id", "provider_id", "name", "merchant_address", "total", "updated_at", "pay_type"]
            hsh  = gift.admt_serialize
            compare_keys hsh, keys

        end

        it "should report_serialize" do
            keys = ["order_num","updated_at","created_at","receiver_name","items","server","total"]
            hsh  = gift.report_serialize
            compare_keys hsh, keys

        end

        it "should promo_serialize" do
            keys = ["value", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items"]
            keys << "receiver_photo" if gift.receiver
            hsh  = gift.promo_serialize
            compare_keys hsh, keys
        end
    end
end

