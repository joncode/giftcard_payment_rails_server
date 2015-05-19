#require 'resque/plugins/resque_heroku_autoscaler'

class MailerJob
    #extend Resque::Plugins::HerokuAutoscaler

    extend Emailer
    @queue = :r_email

    def self.perform(data)
        begin
            self.call_mandrill(data)
        rescue
            puts "No #{data['text']} email ERROR - MailerJob"
        end
    end


private

    def self.call_mandrill data
        puts "data in Email.rb #{data}"
        MailerJob.send(data['text'], data)
    end

end

# reset_password - MtUser
# {"text"=>"reset_password", "user_type"=>"MtUser", "user_id"=>1, "subdomain"=>"qapartner"}