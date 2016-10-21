require 'gcm'

class OpsGooglePush

	class << self

		def send_push pn_token_or_array, alert
			if alert.to_s.match(/has been delivered/)
                hsh = { message: alert,
                        title: 'ItsOnMe Gift Delivered!',
                        args: { gift_id: gift_id }
                    }
            elsif alert.to_s.match(/opened your gift/)
                hsh = { message: alert,
                        title: 'ItsOnMe Gift Opened!',
                        args: { gift_id: gift_id }
                    }
            elsif alert.to_s.match(/got the app/)
                hsh = { message: alert,
                        title: 'Thank You!',
                        args: { gift_id: gift_id }
                    }
            else
                hsh = { message: alert,
                        title: 'New ItsOnMe Gift!',
                        action: 'VIEW_GIFT',
                        args: { gift_id: gift_id }
                    }
            end
			pn_tokens = parse_input(pn_token_or_array)
			registration_ids = format_push_ids(pn_tokens)
			msg = format_payload(hsh)

			r = perform(registration_ids, msg)
			update_canonical_id(r, pn_tokens)
			r
		end

		def get_canonical_id pn_token
			pn_tokens = parse_input(pn_token)
			registration_ids = format_push_ids(pn_tokens)
			msg = format_payload({ action: 'VERIFY_ID' })
			r = perform(registration_ids, msg)
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

		def perform(registration_ids, msg)
			gcm = GCM.new(GCM_API_KEY)
			r = gcm.send(registration_ids, msg)
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

		def format_payload alert
			if alert.kind_of?(String)
				{ data: { message: alert, title: 'ItsOnMe App' } }
			else
				{ data: alert }
			end
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