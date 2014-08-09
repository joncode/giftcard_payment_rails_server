module Email

#######   Gifts

    def notify_receiver
        gift = self
        obj_email = gift.receiver ? gift.receiver.email : nil
        email     = gift.receiver_email || obj_email

        if !email.blank?
            puts "emailing the gift receiver for #{gift.id}"
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id

            data = {"text"        => 'notify_receiver',
                    "gift_id"     => gift.id
                    }
            route_email_system(data)
        end
    end

    def notify_receiver_boomerang
        gift = self
        obj_email = gift.receiver ? gift.receiver.email : nil
        email     = gift.receiver_email || obj_email

        if !email.blank?
            puts "emailing boomerang notice to the gift receiver for #{gift.id}"
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id

            data = {"text"        => 'notify_receiver_boomerang',
                    "gift_id"     => gift.id
                    }
            route_email_system(data)
        end
    end

    def notify_receiver_proto_join
        gift = self
        obj_email = gift.receiver ? gift.receiver.email : nil
        email     = gift.receiver_email || obj_email

        if !email.blank?
            puts "emailing the gift receiver for #{gift.id}"
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id

            data = {
                "text"    => 'notify_receiver_proto_join',
                "gift_id" => gift.id }
            route_email_system(data)
        end
    end

    def invoice_giver
        gift = self

        puts "emailing the gift giver for #{gift.id}"

        data = {"text"        => 'invoice_giver',
                "gift_id"     => gift.id
                }
        route_email_system(data)
    end

#######   User

    def confirm_email

        data = {"text"        => 'confirm_email',
                "user_id"     => self.id,
                "link"        => self.setting.generate_email_link
                }
        # puts "Here is the data #{data.inspect}"
        route_email_system(data)
    end

    def send_reset_password_email user
        data = {"text"        => 'reset_password',
                "user_id"     => user.id
                }
        route_email_system(data)
    end

private

    def route_email_system data
        puts "data in Email.rb #{data}"
        unless  Rails.env.development?
            Resque.enqueue(MailerJob, data)
        end
    end

end
