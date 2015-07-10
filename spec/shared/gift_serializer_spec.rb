shared_examples_for "gift serializer" do

    it "should serialize" do
        keys = ["items", "gift_id", "giver","giver_photo" ,"receiver" ,"message", "detail", "shoppingCart" ,"merchant_name" ,"merchant_address" ,"merchant_phone", "cat" ]
        keys << "receiver_photo" if object.receiver
        keys << "expires_at"     if object.expires_at
        hsh  = object.serialize
        compare_keys hsh, keys
    end

    it "should badge_serialize" do
        keys = ['merchant_id',"region_id", "region_name", "city_id","value", "r_sys",  "items","giver_id", "giver_name", "provider_id", "provider_name", "message", "detail",  "updated_at", "created_at", "status", "shoppingCart", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "gift_id", "time_ago", "cat" ]
        keys << "expires_at"     if object.expires_at
        hsh  = object.badge_serialize
        compare_keys hsh, keys
    end

    it "should giver_serialize" do
        keys = ['merchant_id',"region_id", "region_name", "city_id","items","created_at", "r_sys", "message", "detail",  "provider_id", "provider_name", "receiver_id", "receiver_name", "value", "cost", "updated_at", "shoppingCart", "gift_id", "status", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "time_ago", "cat" ]
        keys << "completed_at"   if object.redeemed_at
        keys << "expires_at"     if object.expires_at
        keys << "receiver_photo" if object.receiver
        hsh  = object.giver_serialize
        compare_keys hsh, keys
    end

    it "should receiver_serialize" do
        keys = ['merchant_id',"region_id", "region_name", "city_id","items","giver_id","r_sys",  "giver_name", "message", "detail",  "provider_id", "provider_name", "shoppingCart", "updated_at", "created_at", "gift_id", "status", "giver_photo", "provider_photo", "provider_phone", "city", "latitude", "longitude", "live", "provider_address", "time_ago", "cat" ]
        keys << "completed_at" if object.redeemed_at
        keys << "expires_at"   if object.expires_at
        hsh  = object.receiver_serialize
        compare_keys hsh, keys

    end

    it "should admt_serialize" do
        keys = ["gift_id", "provider_id", "name", "merchant_address", "value", "cost", "updated_at", "pay_type", "cat", "detail" ]
        keys << "expires_at"     if object.expires_at
        hsh  = object.admt_serialize
        compare_keys hsh, keys
    end

    it "should report_serialize" do
        keys = ["order_num","updated_at","created_at","receiver_name","items","server","value", "cost", "cat", "detail" ]
        keys << "completed_at" if object.redeemed_at
        keys << "expires_at"   if object.expires_at
        hsh  = object.report_serialize
        compare_keys hsh, keys
    end

    it "should promo_serialize" do
        keys = ["value", "cost", "receiver_name", "receiver_email", "shoppingCart", "status", "updated_at", "created_at", "items", "cat", "detail" ]
        keys << "completed_at"   if object.redeemed_at
        keys << "expires_at"     if object.expires_at
        keys << "receiver_photo" if object.receiver
        hsh  = object.promo_serialize
        compare_keys hsh, keys
    end

end
