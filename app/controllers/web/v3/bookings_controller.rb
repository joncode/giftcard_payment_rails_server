class Web::V3::BookingsController < MetalCorsController
    before_action :authentication_no_token, only: [ :inquiry, :accept, :show ]

    def show
    	bk = Booking.find_with(params[:id])
		if bk
			success bk.serialize
		else
			fail_web({ err: "NOT_FOUND" })
		end
		respond
    end

    def resubmit
    	bk = Booking.find_with(params[:id])
		if bk.resubmit
			success bk.serialize
		else
			fail_web({ err: "NOT_FOUND" })
		end
		respond
    end

	def inquiry
		h = parse_params_to_datetimes(create_params)
		puts h.inspect
		h[:date1] = TimeGem.add_time_to_date(h[:time1], h[:date1])
		h[:date2] = TimeGem.add_time_to_date(h[:time2], h[:date2])
		book = Book.find(h[:book_id])
		bk = Booking.new(h)
		bk.price_id = h[:price_id]
		puts bk.inspect
		if h[:price_id].present?
			if bk.save
				bk.customer_submits_inquiry
				success bk.serialize
			else
				fail_web({ err: "INVALID_INPUT", msg: bk.errors.full_messages })
			end
		else
			fail_web({ err: "INVALID_INPUT", msg: "price_id field is missing" })
		end
		respond
	end

	def accept
			# :agree_tos, :cancellation, :stripe_card_id, :date_accepted
		bk = Booking.find_with(params[:id])
		if !accept_params[:agree_tos] || !accept_params[:cancellation]
			fail_web({ err: "INVALID_INPUT", msg: "You must accept the Terms of Service and Cancellation policy" })
		elsif bk.expired?
			fail_web({ err: "INVALID_INPUT", msg: "This booking has expired." })
		else
			if bk && bk.accept_booking(accept_params[:stripe_id], accept_params[:stripe_user_id])
				bk.booking_confirmed
				success bk.serialize
			else
				if bk
					fail_web({ err: "INVALID_INPUT", msg: bk.errors.full_messages })
				else
					fail_web({ err: "NOT_FOUND", msg: "No booking found for #{params[:id]}" })
				end
			end
		end
		respond
	end


#	-------------


    def parse_params_to_datetimes params_hsh
    	params_hsh.each_key do |k|
		    # puts k.inspect + params_hsh[k].inspect
		    params_hsh[k] = TimeGem.string_to_datetime(params_hsh[k])
		end
		params_hsh
    end


private

	def accept_params
		params.require(:data).permit( :agree_tos, :cancellation, :stripe_user_id, :stripe_id, :date_accepted )
	end

	def create_params
		params.require(:data).permit( :price_id, :time1, :time2, :date1, :date2, :book_id, :name, :phone, :email, :note, :guests )
	end

end