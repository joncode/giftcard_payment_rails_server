		#   -------------    	OpsInternalPos DEFINITION    	-------------

OpsInternalPos = Struct.new(:redemption, :gift, :server) do

	def inspect
		{ success: success?, ticket_id: ticket_id, applied_value: applied_value,
			response: response, request: make_request_hsh }
	end

	def success?
		true
	end

	def ticket_id
		server
	end

	def applied_value
		redemption.amount
	end

		#   -------------

	def response
    	if success?
    		status = redemption.status
    		redemption.status = 'done'
			h = { "response_code" => 'APPLIED', "response_text"=>{"amount_applied" => applied_value, 'msg' => redemption.msg } }
			redemption.status = status
			h
		else
			{ "response_code" => "ERROR", "response_text"=>{"amount_applied" => 0, 'msg' => 'POS system unavailable' } }
		end
	end

	def make_request_hsh
		{
			"server" => server,
            "gift_card_id" => gift.hex_id,
            "value" => redemption.amount,
            "ccy" => redemption.ccy,
            'redemption_id' => redemption.hex_id
        }
	end

end