module EmailerInternal
	extend ActiveSupport::Concern

    def send_notice data
    	subject = data["subject"]
    	text    = data["text"]
    	email   = data["email"]
		emails  = email.map { |mail| {"email" => mail, "name" => "IOM Staff (#{mail})"} }
		if Rails.env.development? || Rails.env.staging?
			subject_content = subject.insert(0, "QA- ")
		else
			subject_content = subject
		end
        message = {
			"subject"    => subject_content,
			"from_name"  => "IOM Database",
			"text"       => text,
			"to"         => emails,
			"from_email" => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

private

    def request_mandrill_with_message message
		if Rails.env.staging? || Rails.env.production?
	        puts "``````````````````````````````````````````````"
	        puts "Request Mandrill with #{message}"

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