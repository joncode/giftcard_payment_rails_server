class Web::V3::ClientsController < MetalCorsController

	before_action :authenticate_general


	def show
		slug = params[:id]
		client = Client.find_by(url_name: slug)
		if client && client.active
			# success serialize
			success client
		elsif client && !client.active
			# return deactivated client message
			fail_web fail_web_payload("client_deactivated")
		else
			# client does not exist
			fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
		end
		respond
	end

end