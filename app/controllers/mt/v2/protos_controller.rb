class Mt::V2::ProtosController < JsonController
    before_action :authenticate_merchant_tools

    def gifts
        proto  = Proto.find params[:id]
        number = proto.giftables.count
        # if number == 0
        # 	success "Processing Contacts Currently -   #{params[:id]}"
        # 	status = 201
        # else
            if thread_on?
                Resque.enqueue(ProtoGifterJob, proto.id)
            else
                ProtoGifterJob.perform(proto.id)
            end
        	success "Request for #{number} gifts from #{proto.giver_name} received."
        	status = 202
        # end
    	respond(status)
    end

end
