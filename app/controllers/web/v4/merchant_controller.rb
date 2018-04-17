class Web::V4::MerchantController < MetalCorsController

    before_action :authentication_token_required
    before_action :resolve_merchant
    before_action :verify_employee_access, only: [:list_pending]


    # GET /:merchant_id/pending_gifts
    def list_pending
        puts "[api Web::v4::Merchant :: list_pending]"
        redeems = @merchant.pending_redeems
        puts " | responding with: #{redeems}"

        success redeems
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
        #TODO: refactor after fixing `user#highest_access_at`
        unless @current_user.highest_access_at_merchant(@merchant) >= UserAccess.level(:employee)
            fail_web({ err: "UNAUTHORIZED",  msg: "You lack sufficient permissions at this merchant." })
            return respond
        end
    end

end
