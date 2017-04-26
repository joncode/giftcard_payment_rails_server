class Web::V3::BooksController < MetalCorsController
    before_action :authentication_no_token, only: [ :reserve ]

	def reserve
		book_id = params[:id]
		reservation = reserve_params
		reservation[:book_id] = book_id
		bk = Booking.new(reservation)
		if bk.save

		else

		end

	end






private

	def reserve_params
		params.require(:data).permit(:name, :email, :phone, :party, :date1, :date2, :note)
	end


end