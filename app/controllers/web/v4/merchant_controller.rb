class Web::V4::MerchantController < MetalCorsController

    before_action :authentication_token_required
    before_action :resolve_merchant
    before_action :verify_employee_access, only: [:list_pending, :list_recent]


    # GET /:merchant_id/pending_redemptions
    def list_pending
        puts "[api Web::v4::Merchant :: list_pending]"
        redemptions = @merchant.pending_redemptions

        json_redemptions = redemptions.collect do |redemption|
            as_json_with_gift_data(redemption)
        end
        puts " | responding with: #{json_redemptions.as_json}"

        success json_redemptions.as_json
        return respond
    end

    # GET /:merchant_id/recent_redemptions
    def list_recent
        puts "[api Web::v4::Merchant :: list_recent]"
        redemptions = @merchant.recent_redemptions

        json_redemptions = redemptions.collect do |redemption|
            as_json_with_gift_data(redemption)
        end
        puts " | responding with: #{json_redemptions.as_json}"

        success json_redemptions.as_json
        return respond
    end


private

    def resolve_merchant
        @merchant = Merchant.where(id: params[:merchant_id].to_i).first

        if @merchant.nil?
            fail_web({ err: "INVALID_INPUT", msg: "Could not find the specified Merchant" })
            return respond
        end
    end

    def verify_employee_access
        #TODO: refactor after fixing `user#highest_access_level_at`
        unless @current_user.highest_access_level_at(@merchant) >= UserAccess.level(:employee)
            fail_web({ err: "UNAUTHORIZED",  msg: "You lack sufficient permissions at this merchant." })
            return respond
        end
    end

    def as_json_with_gift_data(redemption)
        unless redemption.respond_to? :gift_id
            puts "[api Web::v4::Merchant :: as_json_with_gift_data]  Error"
            puts " | Invalid object passed. Must respond to #gift_id"
            puts " | Got: #{redemption.inspect}"
            raise ArgumentError, "Object does not respond to #gift_id"
        end
        json         = redemption.as_json
        json["gift"] = redemption.gift.serialize.as_json
        json
    end

end
