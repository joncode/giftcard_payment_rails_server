module Email

#######   Gifts

    def notify_receiver thread_it=true
        gift = self
        obj_email = gift.receiver ? gift.receiver.email : nil
        email     = gift.receiver_email || obj_email

        unless email.blank?
            puts "emailing the gift receiver for #{gift.id} #{thread_it}"
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id

            data = {"text"        => 'notify_receiver',
                    "gift_id"     => gift.id
                    }
            route_email_system(data, thread_it)
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

    def invoice_giver thread_it=true
        gift = self
        puts "emailing the gift giver for #{gift.id}"
        data = {"text"        => 'invoice_giver',
                "gift_id"     => gift.id
                }
        route_email_system(data, thread_it)
    end

    def notify_admin
        gift = self
        if gift.value.to_i >= 35 && Rails.env.production?
            if gift.shoppingCart
                items = gift.ary_of_shopping_cart_as_hash
                items = items.map do |item|
                    "#{item["quantity"]} x #{item["item_name"]}"
                end
                items = "of " + items.join(',')
            end
            giver_email = gift.giver.email if Gift.where(giver_id: gift.giver_id).present?
            origin_text = ""
            if gift.origin.present?
                origin_text = 'Gift origin - ' + gift.origin.to_s + '\n'
            end
            email_text = "#{origin_text} #{gift.giver_name} (#{giver_email}) has sent a $#{gift.value} gift #{items} at #{gift.provider_name} to #{gift.receiver_name}"
            data = {
                "subject" => "$35+ Gift purchase made",
                "text"    => email_text,
                "email"   => ADMIN_NOTICE_CONTACT
            }
            #route_internal_email_system(data)
        end
    end

    def notify_developers data=nil
        gift = self

        unless data
            data = {
                "subject" => "Notify Developers",
                "text"    => "#{gift.inspect}",
                "email"   => "jon.gutwillig@itson.me"
            }
        end
        route_internal_email_system(data)

    end

#######   User

    def confirm_email

        data = {"text"        => 'confirm_email',
                "user_id"     => self.id,
                "link"        => self.setting.generate_email_link
                }
        route_email_system(data, false)
    end

    def send_reset_password_email user, email=nil
        data = {"text"    => 'reset_password',
                "user_id" => user.id,
                "email"   => email
                }
        route_email_system(data)
    end

    def reminder_hasnt_gifted
        data = {
            "text"    => "reminder_hasnt_gifted",
            "user_id" => self.id,
        }
        route_email_system(data)
    end

private

    def route_email_system data, thread_it=true
        puts "Email.rb 131 - route_email_system #{data} #{thread_it}"
        unless Rails.env.development?
            if thread_it  # set this to false if you are already on a background thread
                puts "Email.rb 134 - Resque.enqueue(MailerJob, #{data})"
                Resque.enqueue(MailerJob, data)
            else
                puts "Email.rb 137 - MailerJob.perform(#{data})"
                MailerJob.perform(data)
            end
        end
    end

    def route_internal_email_system data
        puts "Email.rb 142 -  route_internal_email_system"
        unless Rails.env.development?
            Resque.enqueue(MailerInternalJob, data)
        end
    end


end
