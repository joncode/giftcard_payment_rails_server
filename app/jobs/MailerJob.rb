class MailerJob
    extend Emailer
    @queue = :r_email

    def self.perform(data)
        begin
            self.call_mandrill(data)
        rescue
            puts "No #{data['text']} email ERROR"
        end
    end


private

    def self.call_mandrill data
        MailerJob.send(data['text'], data)
    end

end