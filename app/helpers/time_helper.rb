module TimeHelper

    def make_date_s date
        if date.respond_to? :strftime
            date.strftime("%m/%d/%Y")
        end
    end

    def format_date date
        if date.kind_of?(String)
            Date.strptime(date, "%m/%d/%Y")
        else
            date
        end
    end

    def change_time_zone_only datetime_obj, time_zone_str
        dt = DateTime.now.in_time_zone(time_zone_str)
        dt.change(year: datetime_obj.year, month: datetime_obj.month, day: datetime_obj.day, hour: datetime_obj.hour)
    end

    def make_ordinalized_date_with_day date
        # "Sunday, Aug 3rd"
        if date.respond_to? :strftime
            date.strftime("%A, %b #{date.day.ordinalize}")
        end
    end
#################################


end