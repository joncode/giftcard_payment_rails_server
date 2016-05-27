require 'gcm'

class OpsGooglePush

	class << self

		def send_push pn_token, alert
			gcm = GCM.new(GCM_API_KEY)

			if alert.kind_of?(String)
				msg =  { data: { message: alert } }
			else
				msg = alert
			end

			if pn_token.canonical_id.present?
				registration_ids = [pn_token.canonical_id]
			else
				registration_ids = [pn_token.pn_token] # an array of one or more client registration tokens
			end
			r = gcm.send(registration_ids, msg)

			update_canonical_id r, pn_token
			r
		end


		def update_canonical_id r, pn_token
			if r[:canonical_ids][0].present? && (r[:canonical_ids][0][:new] != pn_token.pn_token)
				if pn_token.canonical_id.nil?
					pn_token.update(canonical_id: r[:canonical_ids][0][:new])
				end
			end
		end

	end

end