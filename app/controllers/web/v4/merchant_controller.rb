class Web::V4::MerchantController < MetalCorsController

    before_action :authentication_token_required
    before_action :resolve_merchant
    before_action :verify_employee_access


    # ---[ V2: List Redemptions ]---------

    # GET /:merchant_id/pending_redemptions
    def list_pending
        puts "[api Web::v4::Merchant :: list_pending]"
        redemptions = @merchant.pending_redemptions

        json_redemptions = redemptions.collect do |redemption|
            redemption_to_json_with_gift_data(redemption)
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
            redemption_to_json_with_gift_data(redemption)
        end
        puts " | responding with: #{json_redemptions.as_json}"

        success json_redemptions.as_json
        return respond
    end


    # ---[ Printers ]---------
    #TODO: Create a new route for `list_redemption_print_queue` and transition the Mobile App to the new route.

    # NOT LINKED
    def list_print_queue
        # Because the default scope sorts these ascending, and for whatever reason, specifying descending (even on the same colum) attempts to perform both orders. simultaneously.  BLOODY BRILLIANT.
        queue = PrintQueue.unscoped.where(merchant: @merchant).where('created_at >= ?', 24.years.ago).order(created_at: :desc)
        queue.collect!{|job| job_to_json_with_redemption_data(job) }

        success(queue) and respond
    end


    # GET  /:merchant_id/printer/queue
    def list_redemption_print_queue
        # Because the default scope sorts these ascending, and for whatever reason, specifying descending (even on the same colum) attempts to perform both orders. simultaneously.  BLOODY BRILLIANT.
        queue = PrintQueue.unscoped.where(merchant: @merchant).where('created_at >= ?', 24.hours.ago).order(created_at: :desc)
        queue = queue.collect do |job|
            # Only list redemption (gift) print jobs  (exclude shift reports, etc.)
            (job.redemption.present? ? job_to_json_with_redemption_data(job) : nil)
        end.compact

        success(queue) and respond
    end

    # POST /:merchant_id/printer/reprint/:id
    def reprint
        redemption = Redemption.find_with(params[:id])  rescue nil
        if redemption.nil?
            fail_web({ err: "INVALID_INPUT", msg: "Redemption not found" })
            return respond
        end

        print_queue = PrintQueue.reprint_redemption(redemption)
        if print_queue.nil? || !print_queue.persisted?
            msg = "Redemption #{redemption.paper_id} reprint error.  "
            msg += print_queue.errors.messages  rescue ""

            fail_web({ msg: msg.trim })
            return respond
        end

        success({ msg: "Redemption #{redemption.paper_id} scheduled for reprint" })
        respond
    end

    # POST /:merchant_id/printer/shift_report
    def print_shift_report
        pq = PrintQueue.queue_shift(@merchant)

        if pq.is_a? PrintQueue
            success pq
        else
            fail_web({ msg: "Failed to queue a Shift Report" })
        end
        respond
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

    def redemption_to_json_with_gift_data(redemption)
        unless redemption.respond_to? :gift_id
            puts "[api Web::v4::Merchant :: redemption_to_json_with_gift_data]  Error"
            puts " | Invalid object passed. Must respond to #gift_id"
            puts " | Got: #{redemption.inspect}"
            raise ArgumentError, "Object does not respond to #gift_id"
        end
        json         = redemption.as_json
        json["gift"] = redemption.gift.serialize.as_json
        json
    end

    def job_to_json_with_redemption_data(job)
        # Only jobs including redemptions will have a gift.
        # (Non-redemption jobs include shift reports, help, recall notices, etc.)
        return job.as_json  unless job.redemption.present?

        # Convert the data to json and include it within our print job data.
        json_redemption = job.redemption.serialize
        json_gift       = job.redemption.gift.serialize

        json_job = job.as_json
        json_redemption["gift"] = json_gift
        json_job["redemption"]  = json_redemption

        json_job
    end

end
