require 'gcm'

class OpsGooglePush


	def self.send_push_to_token pn_token, alert
		gcm = GCM.new(GCM_API_KEY)

		registration_ids = [pn_token.pn_token] # an array of one or more client registration tokens
		r = gcm.send(registration_ids, { data: { message: alert } } )
	end



end