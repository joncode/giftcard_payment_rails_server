class Ditto < ActiveRecord::Base
	belongs_to :notable, polymorphic: true

	def response
		begin
			JSON.parse self.response_json
		rescue
			self.response_json
		end
	end

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

		def receive_pos_create(request, response, redeem_id, status)
			request_response_hash = { request: request, response: response }
			create(response_json: request_response_hash.to_json, cat: 1000, status: parse_pos_status(status), notable_id: redeem_id, notable_type: 'Redeem')
		end

		def tokenize_card(response, card_id)
			status        = parse_authorize_net_response(response)
			response_json = PaymentGatewayCim.response_json(response)
			create(response_json: response_json, cat: 600, status: status, notable_id: card_id, notable_type: "Card")
		end

	private

		def parse_authorize_net_response(response)
			if !response.kind_of? AuthorizeNet::CIM::Response
				return 500
			else
				if response.success?
					if response.profile_id && response.payment_profile_ids
						return 200
					else
						return 400 #transaction successful, but expected values not returned
					end
				else
					if response.message_code == "E0039"
						return 304 #A duplicate record already exists
					elsif response.message_code == "E0040"
						return 404 # The record cannot be found
					end
				end
			end
			400
		end

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

		def parse_pos_status(status)
			if status == :ok
				return 200
			elsif status == :bad_request
				return 400
			elsif status == :not_found
				return 404
			end
		end

	end
end




# CATEGORIES

#  100 - Register Push Pn Token
#  110 - send push pn token
#  310 - send transactional email
#  400 - Register subscribe email to mailchimp
#  500 - SocialProxy
#  600 - Auth.net - tokenize
# 1000 - Receive POS request


# Statuses

# 500 - No response
# 422 - bad request - data value is incorrect
# 304 - external service already has object
# 200 - ok










