class TimeGem

#   -------------

    # Purpose : an object that has both database utc time, screen times in local time zone, url friendly date strings
    #     :utc (datetime)
    #     :local (datetime)
    #     :url_date (string)
    #     :input date , :time_zone and date_format used.

    # use :utc for PSQL scopes
    # use :local for screen displays
    # use :url_date or :to_s for url safe date strings


    # calling options
        # TimeGem.new
            # now in utc on both local and utc
            # get the current utc date in url format
    # time_zone_str can be an object that responds to :zone
    # datetime_obj can also be a string of format 12-29-2015 or 12/29/2015

    # timezone will be applied to the date entered and :utc will be adjusted in hours

    # daylight savings time is automatically added in
    # time_zones "UTC", "EST", "Pacific Time (US & Canada)" etc

    # ActiveSupport::Time can be buggy
        # do not use Time.now , use DateTime.now

#   -------------


	DATE_FORMAT = "%Y-%m-%d"
    OUTPUT_FORMAT = "%Y-%-m-%-d"
    Time::DATE_FORMATS[:human] = "%b %e, %Y"

#   -------------    CLASS METHODS

    def self.month_name dt
        dt.strftime("%B")
    end

    def self.day_name dt
        dt.strftime("%A")
    end

    def self.dt_to_s dt
        dt.to_formatted_s(:human)
    end

    def self.datetime_to_string dt
        dt.strftime("#{OUTPUT_FORMAT}")
    end

    def self.string_stamp_to_datetime string_stamp
        string_stamp = DateTime.parse(string_stamp) if string_stamp.kind_of?(String)
        string_stamp
    end

    def self.string_to_datetime datetime_obj, time_zone_str="UTC"
        if datetime_obj.kind_of?(String)
            datetime_obj.gsub!('/', '-')
            if datetime_obj.split('-')[2].length == 4
                datetime_obj = DateTime.strptime(datetime_obj + " #{time_zone_str}",  "#{"%m-%d-%Y"} %Z")
            else
                datetime_obj = DateTime.strptime(datetime_obj + " #{time_zone_str}",  "#{DATE_FORMAT} %Z")
            end
        end
        datetime_obj
    end

    def self.change_time_zone_only datetime_obj, time_zone_str
        dt = TimeGem.change_time_to_zone DateTime.now.utc, time_zone_str
        dt.change(year: datetime_obj.year, month: datetime_obj.month, day: datetime_obj.day, hour: datetime_obj.hour)
    end

    def self.change_time_to_zone datetime_obj, time_zone_str
    	if time_zone_str.blank?
    		datetime_obj
    	else
	        datetime_obj.in_time_zone(time_zone_str)
	    end
    end

#   -------------    INSTANCE METHODS

	attr_reader  :date_format, :input, :time_zone, :utc, :local, :url_date

	def initialize time_zone_str=nil, datetime_obj=nil
        time_zone_str = time_zone_str || "UTC"
        puts "TimeGem 25 :input = " + datetime_obj.inspect
		@date_format = DATE_FORMAT
		datetime_obj = datetime_obj || DateTime.now.utc
		@input = datetime_obj
		time_zone_str = time_zone_str.zone if !time_zone_str.kind_of?(String) && time_zone_str.present?
		@time_zone = time_zone_str
		dt = string_to_datetime datetime_obj, @time_zone
		set_zones(dt, @time_zone)
	end

#   -------------

    def to_s
        @url_date
    end

	def string_to_datetime datetime_obj, time_zone_str="UTC"
        TimeGem.string_to_datetime datetime_obj, time_zone_str
	end

	def set_zones datetime_obj, time_zone_str="UTC"
        if datetime_obj.utc?
            @local = TimeGem.change_time_to_zone datetime_obj, time_zone_str
        else
            @local = datetime_obj
        end
        @utc = datetime_obj.utc
        @url_date = @local.strftime("#{OUTPUT_FORMAT}")
	end


end