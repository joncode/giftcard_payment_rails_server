class Admt::V2::ProtosController < JsonController

	before_action :authenticate_admin_tools
	rescue_from JSON::ParserError, :with => :bad_request

	def gifts
		proto = Proto.find params[:id]
		number = proto.giftables.count
        if number == 0
        	success "All gifts have already been created for gift prototype #{params[:id]}"
        	status = 201
        else
			Resque.enqueue(ProtoGifterJob, proto.id)
        	success "Request for #{number} gifts from #{proto.giver_name} received."
        	status = 202
        end
    	respond(status)	end


end
