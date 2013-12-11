module GiftSerializers

    def serialize
        sender      = giver
        merchant    = provider
        gift_hsh                       = {}
        gift_hsh["gift_id"]            = self.id
        gift_hsh["giver"]              = sender.name
        gift_hsh["giver_photo"]        = sender.get_photo
        if receipient = receiver
            gift_hsh["receiver_photo"]     = receiver.get_photo
        end
        gift_hsh["receiver"]           = receiver_name
        gift_hsh["message"]            = message
        gift_hsh["shoppingCart"]       = ary_of_shopping_cart_as_hash
        gift_hsh["merchant_name"]      = merchant.name
        gift_hsh["merchant_address"]   = merchant.full_address
        gift_hsh["merchant_phone"]     = merchant.phone
        gift_hsh
    end

    def badge_serialize
        gift_hsh = self.serializable_hash only: [:giver_id, :giver_name, :provider_id, :provider_name, :message, :updated_at, :created_at]
        gift_hsh["status"]             = self.receiver_status
        gift_hsh["shoppingCart"]       = self.shoppingCart #ary_of_shopping_cart_as_hash
        gift_hsh["giver_photo"]        = giver.get_photo
        gift_hsh["provider_photo"]     = provider.get_photo
        gift_hsh["provider_phone"]     = provider.phone
        gift_hsh["city"]               = provider.city
        gift_hsh["latitude"]           = provider.latitude
        gift_hsh["longitude"]          = provider.longitude
        gift_hsh["live"]               = provider.live_int
        gift_hsh["provider_address"]   = provider.complete_address
        gift_hsh["gift_id"]            = self.id
        gift_hsh
    end

    def giver_serialize
        gift_hsh = self.serializable_hash only: ["created_at", "message", "provider_id", "provider_name", "receiver_id", "receiver_name", "value", "updated_at", "shoppingCart"]
        gift_hsh["gift_id"]            = self.id
        gift_hsh["status"]             = self.giver_status
        if receipient = receiver
            gift_hsh["receiver_photo"]     = receiver.get_photo
        end
        gift_hsh["provider_photo"]     = provider.get_photo
        gift_hsh["provider_phone"]     = provider.phone
        gift_hsh["city"]               = provider.city
        gift_hsh["latitude"]           = provider.latitude
        gift_hsh["longitude"]          = provider.longitude
        gift_hsh["live"]               = provider.live_int
        gift_hsh["provider_address"]   = provider.complete_address
        gift_hsh
    end

    def receiver_serialize
        gift_hsh = self.serializable_hash only: ["giver_id", "giver_name", "message", "provider_id", "provider_name", "shoppingCart", "updated_at", "created_at"]
        gift_hsh["gift_id"]            = self.id
        gift_hsh["status"]             = self.receiver_status
        gift_hsh["giver_photo"]        = giver.get_photo
        gift_hsh["provider_photo"]     = provider.get_photo
        gift_hsh["provider_phone"]     = provider.phone
        gift_hsh["city"]               = provider.city
        gift_hsh["latitude"]           = provider.latitude
        gift_hsh["longitude"]          = provider.longitude
        gift_hsh["live"]               = provider.live_int
        gift_hsh["provider_address"]   = provider.complete_address
        gift_hsh
    end

    def admt_serialize
        provider = self.provider
        gift_hsh                       = {}
        gift_hsh["gift_id"]            = self.id
        gift_hsh["provider_id"]        = provider.id
        #gift_hsh["merchant_id"]        = provider.merchant_id if provider.merchant_id
        gift_hsh["name"]               = provider.name
        gift_hsh["merchant_address"]   = provider.full_address
        gift_hsh["value"]              = self.value
        gift_hsh["updated_at"]         = self.updated_at
        gift_hsh["pay_type"]           = self.payable_type
        gift_hsh
    end

    def report_serialize
        gift_hsh                    = {}
        gift_hsh["order_num"]       = self.order_num
        gift_hsh["updated_at"]      = self.updated_at
        gift_hsh["created_at"]      = self.created_at
            # current summary and payment reports use item coun NOT shopping cart ... delete when in sync
        #gift_hsh["shoppingCart"]   = self.shoppingCart
        gift_hsh["receiver_name"]   = self.receiver_name
        gift_hsh["items"]           = JSON.parse(self.shoppingCart).count

        if order = self.order
            server = order.server_code
        else
            server = nil
        end
        gift_hsh["server"]          = server
        gift_hsh["value"]           = self.value
        gift_hsh
    end

    def promo_serialize
        gift_hsh                    = {}
        gift_hsh["updated_at"]      = self.updated_at
        gift_hsh["created_at"]      = self.created_at
        gift_hsh["receiver_name"]   = self.receiver_name
        gift_hsh["receiver_email"]  = self.receiver_email
        if receipient = receiver
            gift_hsh["receiver_photo"]     = receiver.get_photo
        end
        gift_hsh["items"]           = JSON.parse(self.shoppingCart).count
        gift_hsh["shoppingCart"]    = self.shoppingCart
        gift_hsh["value"]           = self.value
        gift_hsh["status"]          = self.giver_status
        gift_hsh
    end

    # def json_cart_serial
    #     gift_hsh                    = {}
    #     gift_hsh["updated_at"]      = self.updated_at
    #     gift_hsh["created_at"]      = self.created_at
    #     gift_hsh["receiver_name"]   = self.receiver_name
    #     gift_hsh["receiver_email"]  = self.receiver_email
    #     gift_hsh["shoppingCart_json"]    = JSON.parse(self.shoppingCart)
    #     gift_hsh["value"]           = self.value
    #     gift_hsh["status"]          = self.giver_status
    #     gift_hsh
    # end

    # def str_cart_serial
    #     gift_hsh                    = {}
    #     gift_hsh["updated_at"]      = self.updated_at
    #     gift_hsh["created_at"]      = self.created_at
    #     gift_hsh["receiver_name"]   = self.receiver_name
    #     gift_hsh["receiver_email"]  = self.receiver_email
    #     gift_hsh["shoppingCart_str"]    = self.shoppingCart
    #     gift_hsh["value"]           = self.value
    #     gift_hsh["status"]          = self.giver_status
    #     gift_hsh
    # end

# def race
#     gs = Gift.order("created_at DESC").limit(20)
#     puts "THE RACE IS BETWEEN #{gs.count} gifts !!"
#     json_times = []
#     str_times  = []
#     5.times do
#         gs.each { |g| g.json_cart_serial }

#         t = Time.now
#         gs.each { |g| g.json_cart_serial }
#         json_times << (Time.now - t) * 1000
#         t2 = Time.now
#         gs.each { |g| g.str_cart_serial }
#         str_times << (Time.now - t2) * 1000
#     end
#     [0,1,2,3,4].each do |ind|
#         diff = json_times[ind] - str_times[ind]
#         puts "Diff #{ind+1} = #{diff}ms"
#     end
# end

end