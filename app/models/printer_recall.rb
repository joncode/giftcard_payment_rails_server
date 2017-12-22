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
        # Notify immediately (when nil), or every 24 hours in production / every 2 minutes in QA
        self.notified_at.nil? || (self.notified_at < (Rails.env.production? ? 24.hours : 2.minutes).ago)
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
