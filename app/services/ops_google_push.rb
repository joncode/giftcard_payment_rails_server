require 'gcm'

class OpsGooglePush

	class << self

		def send_push pn_token_or_array, alert
			unless pn_token_or_array.kind_of?(Array)
				pn_token_or_array = [pn_token_or_array]
			end

			registration_ids = []
			pn_token_or_array.each do |pn_token|
				if pn_token.canonical_id.present?
					registration_ids << pn_token.canonical_id
				else
					registration_ids << pn_token.pn_token
				end
			end

			if alert.kind_of?(String)
				msg =  { data: { message: alert, title: 'ItsOnMe App' } }
			else
				msg = { data: alert }
			end

			gcm = GCM.new(GCM_API_KEY)
			r = gcm.send(registration_ids, msg)
			puts "SENDING PUSH GCM #{r.inspect}"
			update_canonical_id r, pn_token_or_array
			r
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