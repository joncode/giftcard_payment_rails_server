module Email
    extend Emailer

######   Order

    def notify_giver_order_complete
        ####--->  this is not included in new emailers
        puts "emailing the gift giver for #{self.id}"
        # notify the giver via email
        # order is self here
        gift = self.gift
        #Resque.enqueue(EmailJob, 'notify_giver_order_complete', gift.giver_id , {:gift_id => gift.id})
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
        if gift.receiver_email
            puts "emailing the gift receiver for #{gift.id}"
            # notify the receiver via email
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id
            #Resque.enqueue(EmailJob, 'notify_receiver', user_id , {:gift_id => gift.id, :email => gift.receiver_email})
            data = {"text"        => 'notify_receiver_2',
                    "first_id"    => user_id,
                    "options_hsh" => {:gift_id => gift.id, :email => gift.receiver_email},
                    "gift"        => gift
                    }
            route_email_system(data)
        end
    end

    def invoice_giver
        # self is sale
        gift = self.gift
        puts "emailing the gift giver for #{gift.id}"
        #Resque.enqueue(EmailJob, 'invoice_giver', gift.giver_id , {:gift_id => gift.id})
        data = {"text"        => 'invoice_giver_2',
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
            # if Rails.env.production?
            #     # notify the giver via email
            #     Resque.enqueue(EmailJob, 'notify_giver_created_user', gift.giver_id , {:gift_id => gift.id})
            # end
            data = {"text" => 'notify_giver_created_user',
                    "first_id" => gift.giver_id,
                    "options_hsh" =>  {:gift_id => gift.id}
                    }
            route_email_system(data)
        end
    end

    def confirm_email
        ###--->  Do not have this one yet
        # self is user
        if self.email
            if self.confirm[0] == '0'
                # if Rails.env.production?
                #     Resque.enqueue(EmailJob, 'confirm_email', self.id , {})
                # end
                data = {"text" => 'confirm_email',
                        "first_id" => self.id,
                        "options_hsh" =>  {}
                        }
                route_email_system(data)
            end
        end
    end

######    App Controller

    def send_reset_password_email user
        # Resque.enqueue(EmailJob, 'reset_password', user.id, {})
        data = {"text"        => 'reset_password',
                "first_id"    => user.id,
                "options_hsh" =>  {},
                "user"        => user
                }
        route_email_system(data)
    end

private

    def route_email_system data
        if Rails.env.production?
            call_resque(data)
        else
            call_mandrill(data)
        end
    end

    def call_resque data
        Resque.enqueue(EmailJob, data["text"], data["first_id"], data["options_hsh"])
    end

    def call_mandrill data
        Email.send(data['text'], data)
    end

end







