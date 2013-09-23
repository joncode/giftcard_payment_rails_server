module Email
    extend Emailer

######   Order

    def notify_giver_order_complete
        ####--->  this is not included in new emailers
        puts "emailing the gift giver for #{self.id}"
        # notify the giver via email
        # order is self here
        gift = self.gift

        data = {"text" => 'notify_giver_order_complete',
                "first_id" => gift.giver_id,
                "options_hsh" =>  {:gift_id => gift.id}
                }
        route_email_system(data)
    end

#######   Sale

    def notify_receiver
        # self is sale
        gift = self.gift
        obj_email = gift.receiver ? gift.receiver.email : nil
        email     = gift.receiver_email || obj_email

        if !email.blank?
            puts "emailing the gift receiver for #{gift.id}"
            # notify the receiver via email
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id

            data = {"text"        => 'notify_receiver',
                    "first_id"    => user_id,
                    "options_hsh" => {:gift_id => gift.id, :email => email},
                    "gift"        => gift
                    }
            route_email_system(data)
        end
    end

    def invoice_giver
        # self is sale
        gift = self.gift
        puts "emailing the gift giver for #{gift.id}"

        data = {"text"        => 'invoice_giver',
                "first_id"    => gift.giver_id,
                "options_hsh" => {:gift_id => gift.id},
                "gift"        => gift
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
                "first_id"    => self.id,
                "options_hsh" =>  {},
                "user"        => self,
                "link"        => self.setting.generate_email_link
                }
        puts "Here is the data #{data.inspect}"
        route_email_system(data)
    end

######    App Controller

    def send_reset_password_email user

        data = {"text"        => 'reset_password',
                "first_id"    => user.id,
                "options_hsh" =>  {},
                "user"        => user
                }
        route_email_system(data)
    end

private

    def route_email_system data
        begin
            if Rails.env.production? || Rails.env.staging?
                call_mandrill(data)
            end
        rescue
            puts "No #{data['text']} email ERROR"
        end
    end

    def call_resque data
        Resque.enqueue(EmailJob, data["text"], data["first_id"], data["options_hsh"])
    end

    def call_mandrill data
        #puts "data = #{}"
        Email.send(data['text'], data)
    end

end







