module GiftSerializers
    include ActionView::Helpers::DateHelper

    def serialize
        sender      = giver
        unless merchant = self.provider
            merchant = Provider.unscoped.find(self.provider_id)
        end
        gift_hsh                       = {}
        gift_hsh["gift_id"]            = self.id
        gift_hsh["giver"]              = sender.name
        gift_hsh["giver_photo"]        = sender.get_photo
        gift_hsh["receiver_photo"]  = receiver.get_photo if receiver
        gift_hsh["receiver"]           = receiver_name
        gift_hsh["message"]            = message
        gift_hsh["detail"]            = detail
        gift_hsh["shoppingCart"]       = self.shoppingCart
        gift_hsh["items"]              = ary_of_shopping_cart_as_hash
        gift_hsh["merchant_name"]      = merchant.name
        gift_hsh["merchant_address"]   = merchant.full_address
        gift_hsh["merchant_phone"]     = merchant.phone
        gift_hsh["expires_at"]         = self.expires_at if self.expires_at
        gift_hsh["cat"]                = self.cat
        gift_hsh
    end

    def badge_serialize
        gift_hsh = self.serializable_hash only: [ :value, :cat, :giver_id, :giver_name, :provider_id, :provider_name, :message, :detail, :updated_at, :created_at]
        gift_hsh["status"]             = self.status
        gift_hsh["shoppingCart"]       = self.shoppingCart
        gift_hsh["items"]              = ary_of_shopping_cart_as_hash
        gift_hsh["giver_photo"]        = giver.get_photo


        unless provider = self.provider
            provider = Provider.unscoped.find(self.provider_id)
        end
        gift_hsh["provider_photo"]     = provider.get_photo
        gift_hsh["provider_phone"]     = provider.phone
        gift_hsh["city"]               = provider.city
        gift_hsh["latitude"]           = provider.latitude
        gift_hsh["longitude"]          = provider.longitude
        gift_hsh["live"]               = provider.live_int
        gift_hsh["provider_address"]   = provider.complete_address
        gift_hsh["r_sys"]              = provider.r_sys
        gift_hsh["gift_id"]            = self.id
        gift_hsh["time_ago"]           = time_ago_in_words(self.redeem_time.to_time)
        gift_hsh["expires_at"]         = self.expires_at if self.expires_at
        gift_hsh
    end

    def giver_serialize
        gift_hsh = self.serializable_hash only: [ "cat", "created_at", "message", "detail", "provider_id", "provider_name", "receiver_id", "receiver_name", "value", "cost", "updated_at"]
        gift_hsh["completed_at"]       = self.redeemed_at if self.redeemed_at
        gift_hsh["gift_id"]            = self.id
        gift_hsh["status"]             = self.giver_status
        gift_hsh["receiver_photo"]     = receiver.get_photo if receiver
        unless provider = self.provider
            provider = Provider.unscoped.where(id: self.provider_id).first
        end
        gift_hsh["provider_photo"]     = provider.get_photo
        gift_hsh["provider_phone"]     = provider.phone
        gift_hsh["city"]               = provider.city
        gift_hsh["latitude"]           = provider.latitude
        gift_hsh["longitude"]          = provider.longitude
        gift_hsh["live"]               = provider.live_int
        gift_hsh["provider_address"]   = provider.complete_address
        gift_hsh["shoppingCart"]       = self.shoppingCart
        gift_hsh["items"]              = ary_of_shopping_cart_as_hash
        gift_hsh["time_ago"]           = time_ago_in_words(self.redeem_time.to_time)
        gift_hsh["expires_at"]         = self.expires_at if self.expires_at
        gift_hsh
    end

    def receiver_serialize
        gift_hsh = self.serializable_hash only: ["cat", "giver_id", "giver_name", "message", "detail", "provider_id", "provider_name", "updated_at", "created_at"]
        gift_hsh["completed_at"]       = self.redeemed_at if self.redeemed_at
        gift_hsh["gift_id"]            = self.id
        gift_hsh["status"]             = self.status
        gift_hsh["giver_photo"]        = giver.get_photo

        unless provider = self.provider
            provider = Provider.unscoped.find(self.provider_id)
        end
        gift_hsh["provider_photo"]     = provider.get_photo
        gift_hsh["provider_phone"]     = provider.phone
        gift_hsh["city"]               = provider.city
        gift_hsh["latitude"]           = provider.latitude
        gift_hsh["longitude"]          = provider.longitude
        gift_hsh["live"]               = provider.live_int
        gift_hsh["provider_address"]   = provider.complete_address
        gift_hsh["shoppingCart"]       = self.shoppingCart
        gift_hsh["items"]              = ary_of_shopping_cart_as_hash
        gift_hsh["time_ago"]           = time_ago_in_words(self.redeem_time.to_time)
        gift_hsh["expires_at"]         = self.expires_at if self.expires_at
        gift_hsh
    end

    def admt_serialize
        gift_hsh                       = {}
        gift_hsh["gift_id"]            = self.id
        gift_hsh["provider_id"]        = self.provider_id
        unless provider = self.provider
            provider = Provider.unscoped.find(self.provider_id)
        end
        gift_hsh["name"]               = provider_name
        gift_hsh["merchant_address"]   = provider.full_address
        gift_hsh["value"]              = self.value
        gift_hsh["cost"]               = self.cost
        gift_hsh["updated_at"]         = self.updated_at
        gift_hsh["pay_type"]           = self.payable_type
        gift_hsh["expires_at"]         = self.expires_at if self.expires_at
        gift_hsh["cat"]                = self.cat
        gift_hsh["detail"]             = self.detail
        gift_hsh
    end

    def report_serialize
        gift_hsh                    = {}
        gift_hsh["order_num"]       = self.order_num
        gift_hsh["updated_at"]      = self.updated_at
        gift_hsh["created_at"]      = self.created_at
        gift_hsh["receiver_name"]   = self.receiver_name
        gift_hsh["items"]           = ary_of_shopping_cart_as_hash.count
        gift_hsh["server"]          = self.server
        gift_hsh["value"]           = self.value
        gift_hsh["cost"]            = self.cost
        gift_hsh["expires_at"]      = self.expires_at if self.expires_at
        gift_hsh["cat"]             = self.cat
        gift_hsh["completed_at"]    = self.redeemed_at if self.redeemed_at
        gift_hsh["detail"]          = self.detail
        gift_hsh
    end

    def promo_serialize
        gift_hsh                    = {}
        gift_hsh["updated_at"]      = self.updated_at
        gift_hsh["created_at"]      = self.created_at
        gift_hsh["receiver_name"]   = self.receiver_name
        gift_hsh["receiver_email"]  = self.receiver_email
        gift_hsh["receiver_photo"]  = receiver.get_photo if receiver
        gift_hsh["items"]           = ary_of_shopping_cart_as_hash.count
        gift_hsh["shoppingCart"]    = self.shoppingCart
        gift_hsh["value"]           = self.value
        gift_hsh["cost"]            = self.cost
        gift_hsh["status"]          = self.giver_status
        gift_hsh["expires_at"]      = self.expires_at if self.expires_at
        gift_hsh["cat"]             = self.cat
        gift_hsh["completed_at"]    = self.redeemed_at if self.redeemed_at
        gift_hsh["detail"]          = self.detail
        gift_hsh
    end

    def client_serialize
        gift_hsh                  = {}
        gift_hsh["created_at"]    = self.created_at
        gift_hsh["expires_at"]    = self.expires_at
        gift_hsh["completed_at"]  = self.redeemed_at
        gift_hsh["new_token_at"]  = self.new_token_at
        gift_hsh["notified_at"]   = self.notified_at
        gift_hsh["giv_name"]      = self.giver_name
        gift_hsh["giv_photo"]     = self.giver.short_image_url if giver
        gift_hsh["giv_id"]        = self.giver_id
        gift_hsh["giv_type"]      = self.giver_type
        gift_hsh["rec_id"]        = self.receiver_id
        gift_hsh["rec_name"]      = self.receiver_name
        gift_hsh["rec_photo"]     = self.receiver.short_image_url if receiver
        gift_hsh["items"]         = ary_of_shopping_cart_as_hash
        gift_hsh["value"]         = self.value
        gift_hsh["status"]        = self.status
        gift_hsh["cat"]           = self.cat
        gift_hsh["detail"]        = self.detail
        gift_hsh["msg"]           = self.message
        gift_hsh["loc_id"]        = self.provider_id
        gift_hsh["loc_name"]      = self.provider_name
        if gift_provider = Provider.unscoped.where(id: self.provider_id).first
            gift_hsh["loc_phone"]     = gift_provider.phone
            gift_hsh["loc_address"]   = gift_provider.complete_address
            gift_hsh["loc_photo"]     = gift_provider.short_image_url
            gift_hsh["r_sys"]         = gift_provider.r_sys
        end
        gift_hsh["gift_id"]       = self.id
        gift_hsh["token"]         = self.token
        remove_nils(gift_hsh)
    end

    def web_serialize
        client_serialize
    end

end