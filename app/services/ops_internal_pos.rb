		#   -------------    	OpsInternalPos DEFINITION    	-------------

OpsInternalPos = Struct.new(:redemption, :gift, :server) do

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
		redemption.generic_response
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