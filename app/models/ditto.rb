class Ditto < ActiveRecord::Base
	belongs_to :notable, polymorphic: true

	class << self

		def register_push_create(response, user_id)
			status = parse_ua_response(response)
			create(response_json: response.to_json, cat: 100, status: status, notable_id: user_id, notable_type: 'User')
		end

		def send_push_create(response, obj_id, obj_type="Gift")
			status = parse_ua_response(response)
			create(response_json: response.to_json, cat: 110, status: status, notable_id: obj_id, notable_type: obj_type)
		end

		def send_email_create(response, obj_id, obj_type)
			status = parse_mandrill_response(response)
			create(response_json: response.to_json, cat: 310, status: status, notable_id: obj_id, notable_type: obj_type)
		end

		def subscription_email_create(response, obj_id)
			status = parse_mailchimp_response(response)
			create(response_json: response.to_json, cat: 400, status: status, notable_id: obj_id, notable_type: 'UserSocial')
		end

	private

		def parse_mailchimp_response(response)
			return 500 if response.nil?
			if response.kind_of? Hash
				return 200 if response["email"] && response["euid"]
			end
			if response.kind_of? String
				return 304 if response.match(/is already subscribed to the list/)
				return 404 if response.match(/list could not be found/)
			end
			400
		end

		def parse_mandrill_response(response)
			return 500 if response.nil?
			if response.kind_of? Array
				return 200 if response[0]["status"] == "sent"
			end
			400
		end

		def parse_ua_response(response)
			return 500 if response.nil?
			if response.has_key?("error_code")
				if response["error_code"] == 40001
					return 422
				else
					return 400
				end
			end
			200
		end

	end
end




# CATEGORIES

# 100 - Register Push Pn Token
# 110 - send push pn token
# 310 - send transactional email
# 400 - Register subscribe email to mailchimp


# Statuses

# 500 - No response
# 422 - bad request - data value is incorrect
# 304 - external service already has object
# 200 - ok










