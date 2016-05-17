class Events::CallbacksController < MetalCorsController

	def receive_sms
		puts params.inspect
		head :ok
	end






end