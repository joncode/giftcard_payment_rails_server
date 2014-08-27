module EmailerInternal
	extend ActiveSupport::Concern

    def send_notice data
    	subject = data["subject"]
    	text    = data["text"]
    	email   = data["email"]
puts "---1 data #{data.inspect}"
		if Rails.env.development? || Rails.env.staging?
puts "---2"
puts "---2 #{subject}"
			subject_content = subject.insert(0, "QA- ")
		else
puts "---3"
			subject_content = subject
		end
puts "---4 #{subject_content}"
        message = {
        	subject: subject_content,
        	from_name: "IOM Database",
        	text: text,
        	to: [{
        		email: email,
        		name: "IoM Staff (#{email})"
        	}],
        	from_email: NO_REPLY_EMAIL
        }
puts "---5 #{message}"
        request_mandrill_with_message(message).first
    end

private

    def request_mandrill_with_message message
puts "---6"
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