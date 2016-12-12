class MailerSlowerJob

    @queue = :s_email

    def self.perform(data)
        puts "\n MailerSlowerJob #{data.inspect}"
        MailerJob.perform(data)
    end

end

# invite mt user
# {"email"=>"a.funa@loregrd.com", "invitor_name"=>"Jamie Schneider", "merchant_id"=>633, "token"=>"KelHzBg3y7GXgyEB8Ec0hQ", "text"=>"merchant_staff_invite"}
# reset_password - MtUser
# {"text"=>"reset_password", "user_type"=>"MtUser", "user_id"=>1, "subdomain"=>"qapartner"}