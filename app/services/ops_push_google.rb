require 'gcm'

class OpsPushGoogle

	class << self

		def send_push pn_token_or_array, alert, gift_id=nil
			pn_tokens = parse_input(pn_token_or_array)
			registration_ids = format_push_ids(pn_tokens)
			payload = format_payload(alert, gift_id)

			r = perform(registration_ids, payload)
			update_canonical_id(r, pn_tokens)
			r
		end

		def get_canonical_id pn_token
			pn_tokens = parse_input(pn_token)
			registration_ids = format_push_ids(pn_tokens)
			payload = format_payload({ action: 'VERIFY_ID' })
			r = perform(registration_ids, payload)
			if r && r[:canonical_ids][0].present? && r[:canonical_ids][0][:new].present?
				r[:canonical_ids][0][:new]
			else
				body = r[:body]
				data = JSON.parse body
				if data["success"] != 1
					puts "500 Internal - Bad GCM Token #{pn_token.pn_token}"
					nil
				end
			end
		end

		def perform(registration_ids, payload)
			puts "Sending GOOGLE Push #{registration_ids} #{payload}"
			return if Rails.env.development? || Rails.env.test?
			gcm = GCM.new(GCM_API_KEY)
			r = gcm.send(registration_ids, payload)
			puts "SENDING PUSH GCM #{r.inspect}"
			r
		end

		def format_push_ids pn_tokens
			registration_ids = []
			pn_tokens.each do |pn_token|
				if pn_token.canonical_id.present?
					registration_ids << pn_token.canonical_id
				else
					registration_ids << pn_token.pn_token
				end
			end
			registration_ids.uniq
		end

		def format_payload alert, data=nil
			if alert.kind_of?(Hash)
				payload = alert
			else
				if data
					if alert.to_s.match(/has been delivered/)
		                payload = { message: alert,
		                        title: 'ItsOnMe Gift Delivered!',
		                        args: { gift_id: data }
		                    }
		            elsif alert.to_s.match(/opened your gift/)
		                payload = { message: alert,
		                        title: 'ItsOnMe Gift Opened!',
		                        args: { gift_id: data }
		                    }
		            elsif alert.to_s.match(/got the app/)
		                payload = { message: alert,
		                        title: 'Thank You!',
		                        args: { gift_id: data }
		                    }
		            else
		                payload = { message: alert,
		                        title: 'New ItsOnMe Gift!',
		                        action: 'VIEW_GIFT',
		                        args: { gift_id: data }
		                    }
		            end
		        else
	                payload = { message: alert,
	                        title: 'ItsOnMe :)'
	              		}
		        end
		    end
			return { data: payload }
		end

		def parse_input pn_token_or_array
			if pn_token_or_array.kind_of?(Array)
				pn_token_or_array
			else
					# PnToken Object
				[pn_token_or_array]
			end
		end

		def update_canonical_id r, pn_tokens
			r[:canonical_ids].each do |canon_hsh|
				pn_tokens.each do |pn_token|
					if pn_token.canonical_id.nil?
						if canon_hsh[:old] == pn_token.pn_token
							pn_token.update(canonical_id: canon_hsh[:new])
						end
					end
				end
			end
		end

	end

end