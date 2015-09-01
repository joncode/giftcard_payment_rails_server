module EmailerInternal

    def mail_notice_submit_merchant_setup merchant_submit_obj
        subject = "#{merchant_submit_obj['venue_name']} has requested to join"
        signup_obj = nil
        text = "Please login to Admin Tools create account for:\n#{merchant_submit_obj}"

        if merchant_submit_obj["id"].present? && merchant_submit_obj["id"].to_i > 0
            signup_obj = MerchantSignup.find(merchant_submit_obj["id"])
            if signup_obj
                text = "Please login to Admin Tools create account for:\n#{signup_obj.email_body}"
            end
        end

        message = { :subject=> subject_creator(subject),
                    :from_name=> "Merchant Tools",
                    :text => text,
                    :to=> HELP_CONTACT_ARY,
                    :from_email => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

    def mail_notice_merchant_setup merchant_name
        subject = "#{merchant_name} has completed their initial setup"
        message = { :subject=> subject_creator(subject),
                    :from_name=> "Merchant Tools",
                    :text => "Please login to Admin Tools to start reviewing #{merchant_name}",
                    :to=> HELP_CONTACT_ARY,
                    :from_email => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

    def mail_notice_merchant_profile merchant_name
        subject = "#{merchant_name} has updated their profile"
        message = { :subject=> subject_creator(subject),
                    :from_name=> "Merchant Tools",
                    :text => "The change should be reflected in Admin Tools",
                    :to=> HELP_CONTACT_ARY,
                    :from_email => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

    def mail_notice_merchant_menu merchant_name
        subject = "#{merchant_name} has updated their menu"
        message = { :subject=> subject_creator(subject),
                    :from_name=> "Merchant Tools",
                    :text => "Please login to Merchant Tools to review",
                    :to=> HELP_CONTACT_ARY,
                    :from_email => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

    def mail_notice_help args
        text = args['text']
        subject = args['subject']
        message = { :subject => subject_creator(subject),
                    :from_name => "Merchant Tools",
                    :text => text,
                    :to => HELP_CONTACT_ARY,
                    :from_email => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

    def send_notice data
        subject = data["subject"]
        text    = data["text"]
        email   = data["email"]
        emails  = email.map { |mail| {"email" => mail, "name" => "IOM Staff (#{mail})"} }
        message = {
            "subject"    => subject_creator(subject),
            "from_name"  => "IOM Database",
            "text"       => text,
            "to"         => emails,
            "from_email" => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

    private

    def default_email_msg_for_brand_reps(merchant)
        subj = "We're on It's On Me and I'd like to introduce you to their team"
        body = "I would like to set up a meeting between you and David Leibner from It's On Me (#{WWW_URL}). The meeting can be just the two of you or all three of us.\n"
        body += "We have placed ourselves on the It's On Me platform to help increase our sales and marketing opportunities and would love to see how you think we can all work together to help increase our sales (and yours).\n\n"
        body += "What is It's On Me?\n\n"
        body += "For my Business\n\n"
        body += "It’s On Me is a turn-key mobile gifting and marketing platform.\n\n"
        body += "There is a real-time mobile solution for almost all goods and services consumers use today.\n"
        body += " - Need a cab or limo right now? ... Uber\n"
        body += " - Need a hotel room right now? ... Hotels Tonight\n"
        body += " - Need a reservation right now? ... Open Table\n"
        body += " - Need to send a friend, client or loved on a gift right now? ... introducing It's On Me\n\n"
        body += "See how It's On Me drives your business revenue.\n\n"
        body += "For Consumers\n\n"
        body += "It's On Me is the coolest new way to send someone a gift in real time.\n"
        body += " - Consumers spent $134 Billion dollars in gift cards last year.\n"
        body += " - Social Media platforms like Facebook are sending out 50 million birthday alerts a day, every single day.\n"
        body += " - Consumers are ready and looking for a Real-Time Gifting solution allowing them to say 'Thanks' or 'Congrats' to anyone, anywhere, anytime.\n"
        body += " - Who is using It's On Me to gift in real time? These people are. (#{WWW_URL}who)\n\n"
        body += "From co-op dollars to bar buys I believe there is a better way for us to work together driving more people into this venue and directing them to your products. I think Rachel can share with you many of the programs that have been working so far and maybe we can figure something out for us."
        return subj, body
    end

    def subject_creator(subject)
        if Rails.env.development? || Rails.env.staging?
            subject.insert(0, "QA- ")
        else
            subject
        end
    end

    def request_mandrill_with_message message
        if Rails.env.staging? || Rails.env.production?
            puts "``````````````````````````````````````````````"
            puts " EmailerInternal[120] - Request Mandrill with #{message}"

            require 'mandrill'
            m        = Mandrill::API.new
            response = m.messages.send message
            puts
            puts "Here is the Mandrill response = #{response.first}"
            puts "``````````````````````````````````````````````"
            return response
        else
            response = { "reject_reason" => nil, "status" => "sent" }
        end
    end
end
