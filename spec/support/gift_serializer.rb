shared_examples_for "gift serializer" do

    it "should serialize" do
        keys = [ "gift_id", "giver","giver_photo" ,"receiver" ,"message","shoppingCart" ,"merchant_name" ,"merchant_address" ,"merchant_phone", "expires_at", "cat" ]
        keys << "receiver_photo" if gift.receiver
        hsh  = gift.serialize
        compare_keys hsh, keys
    end

    it "should badge_serialize" do
        keys = ["giver_id", "giver_name", "provider_id", "provider_name", "message", "updated_at", "created_at", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "gift_id", "time_ago", "expires_at", "cat" ]
        hsh  = gift.badge_serialize
        compare_keys hsh, keys
    end

    it "should giver_serialize" do
        keys = ["created_at", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "value", "cost", "updated_at", "shoppingCart", "gift_id", "status", "receiver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "time_ago", "expires_at", "cat" ]
        keys << "receiver_photo" if gift.receiver
        hsh  = gift.giver_serialize
        compare_keys hsh, keys
    end

    it "should receiver_serialize" do
        keys = ["giver_id", "giver_name", "message", "provider_id", "provider_name", "shoppingCart", "updated_at", "created_at", "gift_id", "status", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "time_ago", "expires_at", "cat" ]
        hsh  = gift.receiver_serialize
        compare_keys hsh, keys

    end

    it "should admt_serialize" do
        keys = ["gift_id", "provider_id", "name", "merchant_address", "value", "cost", "updated_at", "pay_type", "expires_at", "cat" ]
        hsh  = gift.admt_serialize
        compare_keys hsh, keys
    end

    it "should report_serialize" do
        keys = ["order_num","updated_at","created_at","receiver_name","items","server","value", "cost", "expires_at", "cat" ]
        hsh  = gift.report_serialize
        compare_keys hsh, keys
    end

    it "should promo_serialize" do
        keys = ["value", "cost", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items", "expires_at", "cat" ]
        keys << "receiver_photo" if gift.receiver
        hsh  = gift.promo_serialize
        compare_keys hsh, keys
    end

end
