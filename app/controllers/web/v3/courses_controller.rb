class Web::V3::CoursesController < MetalCorsController

    before_action :authentication_no_token, only: [:index, :revenue]

    GOLFNOW_ID = Rails.env.staging? ? 28 : 31

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
        else
            begin
                start_date = TimeGem.string_to_datetime(params[:start_date]).beginning_of_day
                end_date = TimeGem.string_to_datetime(params[:end_date]).beginning_of_day

                gs = Gift.get_purchases_for_affiliate(GOLFNOW_ID, start_date, end_date)

                resp = {}
                gs.each do |gift|
                    client = gift.client
                    if client.nil? && resp['Missing'].nil?
                        resp['NA'] = { start_date: params[:start_date], end_date: params[:end_date], url: 'no_client', revenue: 0 }
                    elsif resp[client.id].nil?
                        resp[client.id] = { start_date: params[:start_date], end_date: params[:end_date], url: client.url_name, revenue: 0 }
                    end
                    if client.nil?
                        resp['NA'][:revenue] += gift.value_cents
                    else
                        resp[client.id][:revenue] += gift.value_cents
                    end
                end
                ary_resp = resp.values
                success(ary_resp)
            rescue => e
                puts "500 Internal golfnow api error - #{e.inspect}"
                fail_web({ err: "INVALID_INPUT", msg: "Data could not be proccessed"})
            end
        end
        respond
    end

end