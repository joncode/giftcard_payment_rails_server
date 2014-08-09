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

#################################


end