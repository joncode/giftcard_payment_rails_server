class MailerJob
    @queue = :email

    def self.perform(type_of, message)
        puts "this is email #{type_of}"
        puts "here is message #{message}"
    end
    

end