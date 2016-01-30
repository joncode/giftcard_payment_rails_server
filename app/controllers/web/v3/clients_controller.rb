class Web::V3::ClientsController < MetalCorsController

	before_action :authenticate_general


	def show
		slug = params[:id]
		client = Client.find_by_sql("select * from clients where url_name = '#{slug}' OR download_url = '#{slug}' limit 1").first
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