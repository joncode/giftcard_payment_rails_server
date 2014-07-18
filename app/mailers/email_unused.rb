module EmailUnused

######   Order

    def notify_giver_order_complete
        ####--->  this is not included in new emailers
        puts "emailing the gift giver for #{self.id}"
        # notify the giver via email
        # order is self here
        gift = self.gift

        data = {"text"     => 'notify_giver_order_complete',
                "gift_id"  =>  gift.id
                }
        route_email_system(data)
    end

#######   User

    def email_gift_collected gift
        ###---->  we have connected user to gift - not included
        if gift.receiver_email
            puts "emailing the gift giver that gift has been collected for #{gift.id}"

            data = {"text" => 'notify_giver_created_user',
                    "first_id" => gift.giver_id,
                    "options_hsh" =>  {:gift_id => gift.id}
                    }
            route_email_system(data)
        end
    end

private

    def route_email_system data
        puts "data in Email.rb #{data}"
        unless  Rails.env.development?
            Resque.enqueue(MailerJob, data)
        end
    end

end







