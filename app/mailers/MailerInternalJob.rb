class MailerInternalJob
    extend EmailerInternal

    @queue = :r_email

    def self.perform(data)
        begin
            self.send_notice(data)
        rescue
            puts "Internal email ERROR"
        end
    end

end