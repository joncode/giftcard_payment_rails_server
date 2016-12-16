class Web::V3::CoursesController < MetalCorsController

    before_action :authentication_no_token, only: [:index, :revenue]

    def index
        if @current_client.partner_id != GOLFNOW_ID || @current_client.partner_type != 'Affiliate'
                    # closing this API off for non-Golfnow
            fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
        else
            # ms = Merchant.where(affiliate_id: golfnow_id, active: true, live: true, paused: false).where('live_at > ?', 3.days.ago )
            ms = Merchant.where(affiliate_id: GOLFNOW_ID, active: true, live: true, paused: false)
            resp = ms.map { |m| m.golf_serialize }
            success(resp)
        end
        respond
    end

    def revenue
        if @current_client.partner_id != GOLFNOW_ID || @current_client.partner_type != 'Affiliate'
                    # closing this API off for non-Golfnow
            fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
        elsif params[:start_date].blank?
            fail_web({ err: "INVALID_INPUT", msg: "Missing parameter (start_date)"})
        else
            begin
                o = OpsGolfnowRevenue.new(start_date: params[:start_date], end_date: params[:end_date])
                o.perform
                success(o.res)
            rescue => e
                puts "500 Internal golfnow api error - #{e.inspect}"
                fail_web({ err: "INVALID_INPUT", msg: "Data could not be proccessed"})
            end
        end
        respond
    end

end


