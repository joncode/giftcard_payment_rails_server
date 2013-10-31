class GiftFactory

    attr_reader :receiver_name, :giver_id, :giver_name, :message, :credit_card, :provider_id, :provider_name, :receiver_phone, :receiver_email, :twitter, :facebook_id,  :shoppingCart

    attr_reader :total, :service, :receiver_id

    def initialize(gift_params)
        @total       = gift_params["total"]
        @service     = gift_params["service"]
        @receiver_id = gift_params["receiver_id"]
    end

    def total_charge
        amount = total.to_f + service.to_f
        amount.to_s
    end

    def db_revenue
        total_charge
    end

    def merchant_revenue
        "0"
    end

    def purchaser_status
       @receiver_id ? 'notified' : 'incomplete'
    end

    def receiver_status
        @receiver_id ? 'notified' : 'incomplete'
    end

    def bar_status
        'live'
    end

    def merchant_acct_status
        nil
    end

    def admin_status
         @receiver_id ? 'notified' : 'incomplete'
    end

    def receiver_gift_center?
        false
    end

    def purchasor_archive?
       false
    end

    def merchant_orders?
        false
    end

    def merchant_reports?
        false
    end

    def admin_tools?
        true
    end

    def  controller_response
        nil
    end


end