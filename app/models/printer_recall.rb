class PrinterRecall < ActiveRecord::Base

    def name
        self.printer_name
    end

    def type= type_sym
        self.type_of = type_sym.to_s
    end

    def type
        self.type_of
    end

    def should_notify?
        if Rails.env.production?
            printout_pause_time = (self.notified_at < 24.hours.ago)
        else
            printout_pause_time = (self.notified_at < 2.minutes.ago)
        end

        self.notified_at.nil? || printout_pause_time
    end

    def notifying!
        self.notified_at = DateTime.now.utc
        self.save
        self
    end

    def to_epson_xml
        return case(type_of.to_s)
            when 'misconfiguration'
                PrintRecallMisconfiguration.new.to_epson_xml
            when 'faulty'
                PrintRecallFaulty.new.to_epson_xml
            else
                nil
        end
    end

end
