require 'mandrill'

class EmailAbstract

	attr_reader  :mandrill

	def initialize data
		@mandrill = MANDRILL_CLIENT
		data = data
		@template = 'user'
		@from_email = NO_REPLY_EMAIL
		@from_name = SERVICE_NAME
		@message = nil
		@subject = nil
		@body = nil
	end

	def data= data
        @subject = data["subject"]
        if data['email'].kind_of?(String)
            email = [data['email']]
        else
            email = data["email"]
        end
        @to_emails  = email.map { |mail| {"email" => mail, "name" => "ItsOnMe Staff (#{mail})"} }

        @body = data["text"] if data["text"].present?
        @body = data['html'].html_safe if data['html'].present?
        set_email_message_data
	end

	def set_email_message_data
        @message          = {
            "subject"     => @subject,
            "from_name"   => @from_name,
            "from_email"  => @from_email,
            "to"          => @to_email,
            "global_merge_vars" => [
                { "name" => "body", "content" => @body }
            ]
        }
	end

    def send_email
        request_mandrill_with_template @message
    end


#   -------------


    def add_qa_text_to_subject message
        unless Rails.env.production?
            message["subject"].insert(0, "QA - ")
        end
    end

    def request_mandrill_with_template(message)
        puts "``````````````````````````````````````````````"
        if Rails.env.staging? || Rails.env.production?
            # unless Rails.env.development?
            add_qa_text_to_subject(message)
            puts "EmailAbstract[58] - Request Mandrill with TemplateName: user \nMessage:\n#{message} \n"
            response = @mandrill.messages.send_template(@template, nil, message)

            puts "Response from Mandrill #{response.inspect}"

            response
        elsif Rails.env.development?
        	puts "EmailAbstract[66] - Request Mandrill with TemplateName: user \nMessage:\n#{message} \n"
        else
            response = { "reject_reason" => nil, "status" => "sent" }
        end
        puts "``````````````````````````````````````````````"
    end


end