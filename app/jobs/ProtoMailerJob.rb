class ProtoMailerJob

    @queue = :s_email

    def self.perform(data)
        puts "\n ProtoMailerJob #{data.inspect}"
        MailerJob.perform(data)
    end

end
