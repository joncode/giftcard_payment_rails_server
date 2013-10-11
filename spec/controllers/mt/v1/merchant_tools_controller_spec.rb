require 'spec_helper'

describe Mt::V1::MerchantToolsController do

    before do
        @provider = FactoryGirl.create :provider
    end

    describe "#update" do

        {
            name: "jonns",
            address: "101 N 5th st",
            city: "Malibu",
            state: "CA",
            zip: "94057",
            zinger: "fake zinger",
            description: "totally fake description",
            phone: "2152000098"
        }.stringify_keys.each do |type_of, identifier|

            it "should update #{type_of} on provider" do
                merchant_hsh = serialize(@provider)
                merchant_hsh[type_of] = identifier
                merchant_hsh["tz"] = "0"
                # post to the action with token, and merchant hash in normal json
                post :update, format: :json , token: merchant_hsh["token"], data: (merchant_hsh)
                # check that provider is updated with the merchant hash info
                updated_provider = Provider.find @provider.id
                updated_provider.send(type_of).should == identifier
            end
        end
    end

    describe "#orders"  do

        before do
            @start_time     = Time.now.to_date - 1.day
            @end_time       = (@start_time.to_date + 1.day).to_s
        end

        [ nil,
            {page: "new"},
            {page: 'reports'},
            {page: 'reports', start_time: @start_time, end_time: @end_time}
        ].each do |hsh|
            if hsh.nil?
                condition = "nil"
                str_hsh   = nil
            else
                if hsh.has_key? :start_time
                    condition = "daterange report"
                    str_hsh   = hsh.stringify_keys
                else
                    condition = hsh[:page]
                    str_hsh   = hsh.stringify_keys
                end
            end

            it "should return Array with status 200 & 1 for #{condition}" do
                post :orders, format: :json , token: @provider.token, data: str_hsh
                response.status.should    == 200
                json["status"].should     == 1
                json["data"].class.should == Array
            end

        end
    end


    def serialize provider
        provider.serializable_hash only: [:name, :address, :city, :state, :zip, :token, :zinger, :description, :phone]
    end

end


# def initialize(order_hash)
#     time_adjust         = order_hash["updated_at"].to_datetime
#     @giver_id           = order_hash["giver_id"]
#     @giver_name         = order_hash["giver_name"]
#     @message            = order_hash["message"]
#     @order_num          = order_hash["order_num"]
#     @provider_id        = order_hash["provider_id"]
#     @provider_name      = order_hash["provider_name"]
#     @status             = order_hash["status"]
#     @shoppingCart       = order_hash["shoppingCart"]
#     @receiver_photo     = order_hash["receiver_photo"]
#     @receiver_id        = order_hash["receiver_id"]
#     @receiver_name      = order_hash["receiver_name"]
#     @total              = order_hash["total"].to_f
#     @subtotal           = order_hash["subtotal"].to_f
#     @gift_id            = order_hash["gift_id"]
#     @redeem_code        = order_hash["redeem_code"]
#     @server             = order_hash["server"].to_s
#     @updated_at         = time_adjust
#     @time_ago           = screentime time_adjust
#     @roll               = 0.00
#     check_for_old_gift_amounts
# end