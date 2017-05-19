class BookingDateValidator < ActiveModel::Validator

    def validate(record)
        book = record.book
        if book
            earliest_booking_date = book.book_by
            if record.date1 && (record.date1 < earliest_booking_date)
                return record.errors[:primary_date] << "Booking creation was not successful. Date #{record.date1_to_s} is not far enough in advance. Must be after #{earliest_booking_date.to_formatted_s(:only_date)}"
            end
            if record.date2 && (record.date2 < earliest_booking_date)
                return record.errors[:secondary_date] << "Booking creation was not successful. Date #{record.date2_to_s} is not far enough in advance. Must be after #{earliest_booking_date.to_formatted_s(:only_date)}"
            end
        end
    end


end