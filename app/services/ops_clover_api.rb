require 'rest_client'

class OpsCloverApi
#	extend OpsCloverUtils
# https://apisandbox.dev.clover.com/v2/merchant/J4Q1V4P5X0KS0/inventory/items?access_token=f68ee273-bb0a-f0ff-f56c-35a9ef899659
# a = {'merchant_id' => 'J4Q1V4P5X0KS0', 'auth_token' => 'f68ee273-bb0a-f0ff-f56c-35a9ef899659'}
# paid order: HSCB32CSEPWVG
# open order: 32VK1RT0MF54A

	attr_reader :merchant_id, :auth_token, :h

	RestClient.log = 'stdout'

	def initialize args={}
		@h = args.stringify_keys!
		@merchant_id = @h['merchant_id']
		@auth_token = @h['auth_token']
	end

	def get_tender
		return get_api(['tenders'], { filter: 'label==ItsOnMe'}
	end

	def get_hours
		return get_api(['opening_hours'])
	end

	def get_items
		return get_api(['items'])
	end

	def get_order order_id
		return get_api(['orders', order_id])
	end

	def get_order_line_items order_id
		return get_api(['orders', order_id, 'line_items'])
	end

#	def post_order_payment order_id, device_id, amount, tax_amount, note
	def post_order_payment args={}
		@h = args #.stringify_keys!
		if not @h.has_key?(:tax_amount)
			@h[:tax_amount] = 0
		end
		if not @h.has_key?(:note)
			@h[:note] = ORDER_PAYMENT_NOTE
		end
		if @h.has_key?(:order_id) && @h.has_key?(:device_id) && @h.has_key?(:amount)
			order = { id: @h[:order_id] }
			device = { id: @h[:device_id] }
			payment = { order: order,
						tender: CLOVER_TENDER,
						device: device,
						amount: @h[:amount],
						tax_amount: @h[:tax_amount],
						note: @h[:note]}
			puts payment
			return post [:orders, @h[:order_id], :payments], payment.stringify_keys
		end
	end

#	def post_line_item_discount order_id, line_item_id, name, amount
	def post_line_item_discount args={}
		@h = args #.stringify_keys!
		if @h.has_key?(:order_id) && @h.has_key?(:line_item_id) && @h.has_key?(:amount)
			discount = { amount: @h[:amount], name: @h[:name] }
			return post [:orders, @h[:order_id], :line_items, @h[:line_item_id], :discounts ], discount.stringify_keys
		end
	end


#	def reset_auth_token
##		"https://sandbox.dev.clover.com/oauth/token?client_id={appId}&client_secret={appSecret}&code={codeUrlParam}"
#		auth_json = get('oauth', "token?client_id=#{CLOVER_APP_ID}&client_secret=#{CLOVER_APP_SECRET})
#		auth_hash = JSON.parse auth_json
#		@auth_token = auth_hash['access_token']
#	end

#	private


#	-------------    API CONNECT

	def get_api terms=[], query={}
		return get terms_to_resource(terms, query)
	end

	def post_api terms, body
		return post terms_to_resource(terms, {}), body
	end

	def header
		{ :content_type => :json, :accept => :json, 'Authorization' => "Bearer #{@auth_token}" }
	end

	def terms_to_resource terms, query
		terms = [terms] unless terms.kind_of?(Array)
		resource = (['v3/merchants', merchant_id] + terms).join('/')

		query = {} unless query.kind_of?(Hash)
		resource += query[:order_by].present? ? "?order_by=#{query[:order_by]}" : ''
		resource += query[:filter].present? ? "?filter=#{query[:filter]}" : ''
		return resource
	end

    def get resource

         response = RestClient.get(
            "#{CLOVER_BASE_URL}/#{resource}",
            header
        )

		resp = JSON.parse response
        return { status: 1, data: response }

    rescue Exception => e

        puts "\nOpsCloverApi.get - Error code = #{e.inspect}\n\n"
        if e.nil?
            response = { "response_code" => "ERROR", "response_text" => 'Contact Support', "code" => 400, "data" => [] }
            return { status: 0, data: response, res: response }
        else
            return { status: 0, data: e, error: e }
        end
    end

    def post resource, body
    	puts 'resource=' + resource
    	puts 'body=' + body

    	response = RestClient.post(
    		"#{CLOVER_BASE_URL}/#{resource}",
    		body.to_json,
    		header
		)
     	resp = JSON.parse response

	   	puts 'resp=' + resp.inspect
		return { status: 1, data: resp }

    rescue Exception => e

        puts "\nOpsCloverApi.post - Error code = #{e.inspect}\n\n"
        if e.nil?
            response = { "response_code" => "ERROR", "response_text" => 'Contact Support', "code" => 400, "data" => [] }
            return { status: 0, data: response, res: response }
        else
            return { status: 0, data: e, error: e }
        end
    end
end
