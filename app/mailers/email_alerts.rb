require 'mandrill'

class EmailAlerts

	attr_accessor :data, :mandrill

	def initialize data
		@mandrill = Mandrill::API.new
		@data = data
	end

    def send_email data=@data
        subject = data["subject"]
        if data['email'].kind_of?(String)
            email = [data['email']]
        else
            email = data["email"]
        end
        emails  = email.map { |mail| {"email" => mail, "name" => "ItsOnMe Staff (#{mail})"} }
        # message = {
        #     "subject"    => subject,
        #     "from_name"  => "ItsOnMe Alerts",
        #     "to"         => emails,
        #     "from_email" => NO_REPLY_EMAIL
        # }
        body = data["text"] if data["text"].present?
        body = data['html'].html_safe if data['html'].present?
        # request_mandrill_with_message(message).first
        message          = {
            "subject"     => subject,
            "from_name"   => "ItsOnMe Alerts",
            "from_email"  => NO_REPLY_EMAIL,
            "to"          => emails,
            "global_merge_vars" => [
                { "name" => "body", "content" => body }
            ]
        }

        request_mandrill_with_template message
    end

    def request_mandrill_with_message message
        if Rails.env.staging? || Rails.env.production?
            puts "``````````````````````````````````````````````"
            puts " EmailAlerts[32] - request_mandrill_with_message"

            response = @mandrill.messages.send message
            puts
            puts "Here is the Mandrill response = #{response.first}"
            puts "``````````````````````````````````````````````"
            return response
        else
            response = { "reject_reason" => nil, "status" => "sent" }
        end
    end

    def add_qa_text_to_subject message
        unless Rails.env.production?
            message["subject"].insert(0, "QA - ")
        end
    end

    def request_mandrill_with_template(message)
        if Rails.env.staging? || Rails.env.production?
            # unless Rails.env.development?
            puts "``````````````````````````````````````````````"
            add_qa_text_to_subject(message)
            puts "EmailAlerts[50] - Request Mandrill with TemplateName: user \nMessage:\n#{message} \n"
            m = MANDRILL_CLIENT
            response = m.messages.send_template("user", nil, message)

            puts "Response from Mandrill #{response.inspect}"
            puts "``````````````````````````````````````````````"

            response
        else
            response = { "reject_reason" => nil, "status" => "sent" }
        end
    end
end


    # def confirm_email data
    #     user    = User.find(data["user_id"])
    #     subject = "Confirm your email address"
    #     body    = text_for_user_confirm_email(user, data["link"])
    #     bcc     = "info@itson.me"

    #     template_name = "user"
    #     message       = message_hash(subject, user.email, user.name, body, bcc)
    #     request_mandrill_with_template(template_name, message, [data["user_id"], "User"])
    # end