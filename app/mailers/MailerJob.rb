#require 'resque/plugins/resque_heroku_autoscaler'

class MailerJob
    #extend Resque::Plugins::HerokuAutoscaler

    extend Emailer
    @queue = :r_email

    def self.perform(data)
        puts "\n MailerJob #{data.inspect}"
        begin
            self.call_mandrill(data)
        rescue => error
            puts "500 Internal No #{data['text']} email ERROR - MailerJob[14] - #{error}"
        end
    end


private

    def self.call_mandrill data
        puts "data in MailerJob #{data}"
        MailerJob.send(data['text'], data)
    end

end

# invite mt user
# {"email"=>"a.funa@loregrd.com", "invitor_name"=>"Jamie Schneider", "merchant_id"=>633, "token"=>"KelHzBg3y7GXgyEB8Ec0hQ", "text"=>"merchant_staff_invite"}
# reset_password - MtUser
# {"text"=>"reset_password", "user_type"=>"MtUser", "user_id"=>1, "subdomain"=>"qapartner"}