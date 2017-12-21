class PrinterRecall < ActiveRecord::Base

    def type= type
        self.type_of = type
    end

    def type
        self.type_of
    end

    def should_notify?
        self.notified_at.nil? || (self.notified_at < 24.hours.ago)
    end

    def notifying!
        self.notified_at = Time.now
        self.save
        self
    end

    def to_epson_xml
        return case(type_of)
            when 'misconfiguration'
                PrintRecallMisconfiguration.new.to_epson_xml
            when 'faulty'
                PrintRecallFaulty.new.to_epson_xml
            else
                nil
        end
    end

end
