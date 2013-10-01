module Email

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

#######   Sale

    def notify_receiver
        # self is sale
        gift      = self.gift
        obj_email = gift.receiver ? gift.receiver.email : nil
        email     = gift.receiver_email || obj_email

        if !email.blank?
            puts "emailing the gift receiver for #{gift.id}"
            # notify the receiver via email
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id

            data = {"text"        => 'notify_receiver',
                    "gift_id"     => gift.id
                    }
            route_email_system(data)
        end
    end

    def invoice_giver
        # self is sale
        gift = self.gift
        puts "emailing the gift giver for #{gift.id}"

        data = {"text"        => 'invoice_giver',
                "gift_id"     => gift.id
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

    def confirm_email

        data = {"text"        => 'confirm_email',
                "user_id"     => self.id,
                "link"        => self.setting.generate_email_link
                }
        # puts "Here is the data #{data.inspect}"
        route_email_system(data)
    end

######    App Controller

    def send_reset_password_email user

        data = {"text"        => 'reset_password',
                "user_id"     => user.id
                }
        route_email_system(data)
    end

private

    def route_email_system data
        puts "data in Email.rb #{data}"
        if not Rails.env.test? || Rails.env.development?
            Resque.enqueue(MailerJob, data)
        end
    end

end







