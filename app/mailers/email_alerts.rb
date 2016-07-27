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
            email   = data["email"]
        end
        emails  = email.map { |mail| {"email" => mail, "name" => "ItsOnMe Staff (#{mail})"} }
        message = {
            "subject"    => subject,
            "from_name"  => "ItsOnMe Alerts",
            "to"         => emails,
            "from_email" => NO_REPLY_EMAIL
        }
        message['text'] = data["text"] if data["text"].present?
        message['html'] = data['html'].html_safe if data['html'].present?
        request_mandrill_with_message(message).first
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

end