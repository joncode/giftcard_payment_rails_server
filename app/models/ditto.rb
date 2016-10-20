class Ditto < ActiveRecord::Base

	belongs_to :notable, polymorphic: true

#   -------------

	def response
		begin
			JSON.parse self.response_json
		rescue
			self.response_json
		end
	end

#   -------------

	class << self

		def save_response response, status, notable_id=nil, notable_type=nil
			if notable_id
				create(response_json: response.to_json, cat: 700, status: status, notable_id: notable_id, notable_type: notable_type)
			else
				create(response_json: response.to_json, cat: 700, status: status)
			end
		end

		def register_push_create(response, user_id)
			status = parse_ua_response(response)
			create(response_json: response.to_json, cat: 100, status: status, notable_id: user_id, notable_type: 'User')
		end

		def unregister_push_create(response, user_id)
			status = parse_ua_response(response)
			create(response_json: response.to_json, cat: 101, status: status, notable_id: user_id, notable_type: 'User')
		end

		def send_push_create(response, obj_id, obj_type="Gift")
			status = parse_ua_response(response)
			create(response_json: response.to_json, cat: 110, status: status, notable_id: obj_id, notable_type: obj_type)
		end

		def tokens_push_create(response)
			status = parse_ua_response(response)
			create(response_json: response.to_json, cat: 120, status: status)
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
			create(response_json: request_response_hash.to_json, cat: 1000, status: parse_pos_status(status), notable_id: redeem_id, notable_type: 'Gift')
		end

		def tokenize_card(response, card_id)
			status        = parse_authorize_net_response(response)
			response_json = PaymentGatewayCim.response_json(response)
			create(response_json: response_json, cat: 600, status: status, notable_id: card_id, notable_type: "Card")
		end

		def delete_card_token(response, user_id)
			status        = parse_authorize_net_response(response)
			response_json = PaymentGatewayCim.response_json(response)
			create(response_json: response_json, cat: 610, status: status, notable_id: user_id, notable_type: "User")
		end

		def create_customer_profile(response, customer_id)
			status        = parse_authorize_net_response(response)
			response_json = PaymentGatewayCim.response_json(response)
			user_id = customer_id.to_i - NUMBER_ID
			create(response_json: response_json, cat: 650, status: status, notable_id: user_id, notable_type: "User")
		end

		def friends_social_proxy_create response
			create(response_json: response.to_json, cat: 500, status: response["status"], notable_type: "SocialProxy"  )
		end

		def profile_social_proxy_create response
			create(response_json: response.to_json, cat: 510, status: response["status"], notable_type: "SocialProxy"  )
		end

		def post_social_proxy_create response
			create(response_json: response.to_json, cat: 520, status: response["status"], notable_type: "SocialProxy"  )
		end

		def cron_push_create(response)
			create(response_json: response, cat: 2100, notable_type: "UserSocial")
		end

		def collect_incomplete_gifts_create(response, user_social_id)
			create(response_json: response, cat: 3500, notable_type: "UserSocial", notable_id: user_social_id)
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

            case response
            when Urbanairship::Push::PushResponse
                response.status_code
            else
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

#  100 - Urbanairship - Register Push Pn Token
#  101 - Urbanairship - Unregister Push Pn Token
#  110 - Urbanairship - send push pn token
#  120 - Urbanairship - get device tokens
#  310 - Mandrill     - send transactional email
#  400 - Mailchimp    - Register subscribe email to mailchimp
#  500 - SocialProxy  - friends
#  510 - SocialProxy  - profile
#  520 - SocialProxy  - create_post
#  600 - Auth.net     - tokenize
#  650 - Auth.net     - create cutomer profile
#  700 - DittoJob sender in args
# 1000 - POS          - Receive POS request
# 2xxx - Scheduled Jobs
# 2100 - Scheduled Job - pn_tokens
# 3xxx - Internal Callbacks (not external service)
# 3500 - CollectIncompleteGifts

# Statuses

# 500 - No response
# 422 - bad request - data value is incorrect
# 304 - external service already has object
# 200 - ok










# == Schema Information
#
# Table name: dittos
#
#  id            :integer         not null, primary key
#  response_json :text
#  status        :integer
#  cat           :integer
#  notable_id    :integer
#  notable_type  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

