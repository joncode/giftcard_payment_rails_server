module GiftSerializers
    include ActionView::Helpers::DateHelper

#   -------------

    def serialize
        sender = giver
        unless gift_merchant = self.merchant
            gift_merchant = Merchant.unscoped.find(self.merchant_id)
        end
        gift_hsh = {}
        basic_data gift_hsh
        money_and_items gift_hsh
        gift_hsh["giver"]              = sender.name
        gift_hsh["giver_photo"]        = sender.get_photo
        gift_hsh["receiver_photo"]  = receiver.get_photo if receiver
        gift_hsh["receiver"]           = receiver_name
        gift_hsh["message"]            = message
        gift_hsh["detail"]            = detail
        gift_hsh['brand_card'] = self.brand_card ? 'yes' : 'no'
        gift_hsh["scheduled_at"] = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))
        gift_hsh["merchant_name"]      = gift_merchant.name
        gift_hsh["merchant_address"]   = gift_merchant.full_address
        gift_hsh["merchant_phone"]     = gift_merchant.phone
        gift_hsh['display_photo'] = self.display_photo
        if Rails.env.staging?
            gift_hsh['item_photo'] = 'http://res.cloudinary.com/drinkboard/image/upload/v1473460212/xca6kbzgrxzvtef8bkrs.jpg'
        end
        # new email fields
        gift_hsh["receiver_id"] = self.receiver_id
        gift_hsh["delivery_method"] = self.delivery_method
        gift_hsh["delivery_email"] = self.receiver_email
        gift_hsh["delivery_phone"] = self.receiver_phone

        gift_hsh
    end

    def badge_serialize
        gift_hsh = self.serializable_hash only: [ :giver_id, :giver_name, :message, :detail, :updated_at ]
        basic_data gift_hsh
        money_and_items gift_hsh
        gift_hsh["giver_photo"]        = giver ? giver.get_photo : nil

        merchant_serializer_mdot_keys gift_hsh
        gift_hsh["time_ago"]           = time_ago_in_words(self.redeem_time.to_time)
        gift_hsh['brand_card'] = self.brand_card ? 'yes' : 'no'
        gift_hsh["scheduled_at"] = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))

        gift_hsh
    end

    def giver_serialize
        gift_hsh = self.serializable_hash only: [ "message", "detail", "receiver_id", "receiver_name",  "cost", "updated_at"]
        basic_data gift_hsh
        money_and_items gift_hsh
        gift_hsh["completed_at"]       = self.redeemed_at if self.redeemed_at
        gift_hsh["receiver_photo"]     = receiver.get_photo if receiver

        merchant_serializer_mdot_keys gift_hsh

        gift_hsh["time_ago"]           = time_ago_in_words(self.redeem_time.to_time)
        gift_hsh["scheduled_at"] = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))
        gift_hsh['brand_card'] = self.brand_card ? 'yes' : 'no'

        gift_hsh
    end

    def receiver_serialize
        gift_hsh = self.serializable_hash only: ["cat", "giver_id", "giver_name", "message", "detail", "provider_id", "provider_name", "updated_at", "created_at"]
        gift_hsh["completed_at"]       = self.redeemed_at if self.redeemed_at
        gift_hsh["gift_id"]            = self.id
        gift_hsh["status"]             = self.status
        gift_hsh["giver_photo"]        = giver.get_photo
        merchant_serializer_mdot_keys gift_hsh
        money_and_items gift_hsh
        gift_hsh["time_ago"]           = time_ago_in_words(self.redeem_time.to_time)
        gift_hsh["expires_at"]         = self.expires_at if self.expires_at
        gift_hsh["scheduled_at"] = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))
        gift_hsh['brand_card'] = self.brand_card ? 'yes' : 'no'

        gift_hsh
    end

    def admt_serialize
        gift_hsh                       = {}
        gift_hsh["gift_id"]            = self.id
        gift_hsh["provider_id"]        = self.merchant_id
        unless gift_merchant = self.merchant
            gift_merchant = Merchant.unscoped.find(self.merchant_id)
        end
        gift_hsh["name"]               = provider_name
        gift_hsh["merchant_address"]   = gift_merchant.full_address
        gift_hsh["value"]              = self.value
        gift_hsh["cost"]               = self.cost
        gift_hsh["updated_at"]         = self.updated_at
        gift_hsh["pay_type"]           = self.payable_type
        gift_hsh["expires_at"]         = self.expires_at if self.expires_at
        gift_hsh["scheduled_at"] = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))
        gift_hsh["cat"]                = self.cat
        gift_hsh["ccy"]                = self.ccy
        gift_hsh["detail"]             = self.detail
        gift_hsh
    end

    def report_serialize
        gift_hsh                    = {}
        gift_hsh["order_num"]       = self.order_num
        gift_hsh["updated_at"]      = self.updated_at
        gift_hsh["created_at"]      = self.created_at
        gift_hsh["receiver_name"]   = self.receiver_name
        money_and_items gift_hsh
        gift_hsh["server"]          = self.server
        gift_hsh["cost"]            = self.cost
        gift_hsh["expires_at"]      = self.expires_at if self.expires_at
        gift_hsh["scheduled_at"] = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))
        gift_hsh["cat"]             = self.cat
        gift_hsh["completed_at"]    = self.redeemed_at if self.redeemed_at
        gift_hsh["detail"]          = self.detail
        gift_hsh['brand_card'] = self.brand_card ? 'yes' : 'no'

        gift_hsh
    end

    def promo_serialize
        gift_hsh                    = {}
        gift_hsh["cat"]             = self.cat
        gift_hsh["status"]          = self.status
        gift_hsh["created_at"]      = self.created_at
        gift_hsh["expires_at"]      = self.expires_at if self.expires_at
        money_and_items gift_hsh
        gift_hsh["updated_at"]      = self.updated_at
        gift_hsh["receiver_name"]   = self.receiver_name
        gift_hsh["receiver_email"]  = self.receiver_email
        gift_hsh["receiver_photo"]  = receiver.get_photo if receiver
        gift_hsh["cost"]            = self.cost
        gift_hsh["scheduled_at"] = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))
        gift_hsh["completed_at"]    = self.redeemed_at if self.redeemed_at
        gift_hsh["detail"]          = self.detail
        gift_hsh['brand_card'] = self.brand_card ? 'yes' : 'no'
        gift_hsh
    end

    def refresh_serialize
        gift_hsh = client_serialize

            # new email fields
        gift_hsh["delivery_method"] = self.delivery_method
        gift_hsh["delivery_email"] = self.receiver_email
        gift_hsh["delivery_phone"] = self.receiver_phone
        gift_hsh
    end

    def client_serialize
        gift_hsh = {}
        basic_data gift_hsh
        money_and_items gift_hsh
        merchant_serializer_web_keys gift_hsh
        giver_data gift_hsh
        receiver_data gift_hsh
        gift_hsh["scheduled_at"]  = self.scheduled_at.to_formatted_s(:url_date) if (self.scheduled_at && (self.status == 'schedule'))
        gift_hsh["notified_at"]   = self.notified_at
        gift_hsh["new_token_at"]  = self.new_token_at
        gift_hsh["completed_at"]  = self.redeemed_at
        gift_hsh["detail"]        = self.detail
        gift_hsh["msg"]           = self.message
        gift_hsh["token"]         = self.token
        # remove_nils(gift_hsh)
        gift_hsh
    end

    def web_serialize
        client_serialize
    end

    def notify_serialize
        gift_hsh = client_serialize
        multi_redemption_web_keys gift_hsh
        gift_hsh
    end

private


    def giver_data gift_hsh
        gift_hsh["giv_name"]      = self.giver_name
        gift_hsh["giv_photo"]     = self.giver.get_photo if giver
        gift_hsh["giv_id"]        = self.giver_id
        gift_hsh["giv_type"]      = self.giver_type
    end

    def receiver_data gift_hsh
        gift_hsh["rec_id"]        = self.receiver_id
        gift_hsh["rec_name"]      = self.receiver_name
        gift_hsh["rec_photo"]     = self.receiver.get_photo if receiver
    end

    def basic_data gift_hsh
        gift_hsh["gift_id"]  = self.id
        gift_hsh["status"] = self.status
        gift_hsh["cat"] = self.cat
        gift_hsh["created_at"] = self.created_at
        gift_hsh["expires_at"] = self.expires_at
    end

    def money_and_items gift_hsh
        gift_hsh['value_cents'] = self.value_cents
        gift_hsh['value'] = self.value
        gift_hsh["shoppingCart"]  = self.shoppingCart
        gift_hsh["items"] = ary_of_shopping_cart_as_hash
        gift_hsh["ccy"] = self.ccy
        gift_hsh['brand_card'] = self.brand_card ? 'yes' : 'no'
        if Rails.env.staging?
            gift_hsh['item_photo'] = self.item_photo
        end
    end

    def multi_redemption_web_keys gift_hsh
        if gift_merchant = Merchant.unscoped.where(id: self.merchant_id).first
            if gift_merchant.client.present?
                arg_scope = proc { ["All"] }
                redemptions_merchants = gift_merchant.client.contents(:merchants, &arg_scope)
                if redemptions_merchants != ["All"]
                    redemptions_merchants = redemptions_merchants.serialize_objs(:redemption)
                end
                gift_hsh['redeem_locs'] = redemptions_merchants
            end
        end
    end

    def merchant_serializer_web_keys gift_hsh
        if gift_merchant = (self.merchant || Merchant.unscoped.where(id: self.merchant_id).first)
            gift_hsh["loc_name"]     = gift_merchant.name
            gift_hsh["loc_phone"]     = gift_merchant.phone
            gift_hsh["loc_address"]   = gift_merchant.complete_address
            gift_hsh["loc_street"]   = gift_merchant.address
            gift_hsh["loc_city"]   = gift_merchant.city_name
            gift_hsh["loc_state"]   = gift_merchant.state
            gift_hsh["loc_zip"]   = gift_merchant.zip
            gift_hsh["loc_photo"]     = gift_merchant.get_photo
            gift_hsh['display_photo'] = gift_merchant.get_photo
            gift_hsh['loc_logo']      = gift_merchant.get_logo_web
            gift_hsh["r_sys"]         = gift_merchant.r_sys
            gift_hsh['city_id']       = gift_merchant.city_id
            gift_hsh['region_id']     = gift_merchant.region_id
            gift_hsh['region_name']   = gift_merchant.region_name
            if gift_merchant.client.present?
                gift_hsh['multi_loc'] = 'yes'
            else
                gift_hsh['multi_loc'] = 'no'
            end
        end
        gift_hsh["loc_id"] = self.merchant_id
        gift_hsh["loc_name"] = self.provider_name if gift_hsh["loc_name"].blank?
        gift_hsh
    end

    def merchant_serializer_mdot_keys gift_hsh
        unless gift_merchant = self.merchant
            gift_merchant = Merchant.unscoped.find(self.merchant_id)
        end
        gift_hsh["provider_id"]        = self.merchant_id
        gift_hsh["merchant_id"]        = self.merchant_id
        gift_hsh["provider_name"]      = self.provider_name
        gift_hsh["provider_photo"]     = gift_merchant.get_photo
        gift_hsh["provider_phone"]     = gift_merchant.phone
        gift_hsh["city"]               = gift_merchant.city_name
        gift_hsh["latitude"]           = gift_merchant.latitude
        gift_hsh["longitude"]          = gift_merchant.longitude
        gift_hsh["live"]               = gift_merchant.live_int
        gift_hsh["provider_address"]   = gift_merchant.complete_address
        gift_hsh["r_sys"]              = gift_merchant.r_sys
        gift_hsh['city_id']            = gift_merchant.city_id
        gift_hsh['region_id']          = gift_merchant.region_id if gift_merchant.region_id
        gift_hsh['region_name']        = gift_merchant.region_name if gift_merchant.region_name
        if gift_merchant.client.present?
            gift_hsh['multi_loc'] = 'yes'
        else
            gift_hsh['multi_loc'] = 'no'
        end

        return gift_hsh
    end
end