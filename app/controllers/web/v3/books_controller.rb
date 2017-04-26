class Web::V3::BookingsController < MetalCorsController
    before_action :authentication_no_token, only: [ :inquiry ]

	def inquiry
		h = parse_params_to_datetimes(create_params)
		h[:book_id] = params[:id]
		h[:date1] = add_time_to_date(h[:time1], h[:date1])
		h[:date2] = add_time_to_date(h[:time2], h[:date2])
		bk = Booking.new(h)
		if bk.save
			success bk
		else
			fail_web({ err: "INVALID_INPUT", msg: bk.errors.full_messages })
		end
		respond
	end

    def parse_params_to_datetimes params_hsh
    	params_hsh.each_key do |k|
		    puts k.inspect + params_hsh[k].inspect
		    params_hsh[k] = TimeGem.string_to_datetime(params_hsh[k])
		end
		params_hsh
    end

	def add_time_to_date time, datetime_obj
		puts "ADDING #{time} to #{datetime_obj}"
		return if time.blank? || time.to_i == 0
		return unless datetime_obj.respond_to?(:ago)
		mins = 0
		if time.match(/:30/)
			mins = 30
		end
		tt = time.to_i
		tt = 0 if tt == 12
		if time.match(/PM/i)
			tt += 12
		end
		datetime_obj = datetime_obj.beginning_of_day + tt.hours + mins.minutes
	end


private

	def create_params
		params.require(:booking).permit( :time1, :time2, :date1, :date2, :book_id, :name, :phone, :email, :note, :guests, :price_unit )
	end
end