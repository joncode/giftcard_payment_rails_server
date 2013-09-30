class MailerJob
    extend Emailer
    @queue = :email

    def self.perform(data)
        begin
            if not Rails.env.test?
                self.call_mandrill(data)
            end
        rescue
            puts "No #{data['text']} email ERROR"
        end
    end


private

    def self.call_mandrill data
        MailerJob.send(data['text'], data)
    end

end