require 'rest_client'

class OpsCloverApi
		#	extend OpsCloverUtils
		# https://apisandbox.dev.clover.com/v2/merchant/J4Q1V4P5X0KS0/inventory/items?access_token=f68ee273-bb0a-f0ff-f56c-35a9ef899659
		# a = {'merchant_id' => 'J4Q1V4P5X0KS0', 'auth_token' => 'dec6d9ae-13d4-b71c-ce48-7d1617b036de'}
		# paid order: HSCB32CSEPWVG
		# open order: 32VK1RT0MF54A
		# d = { order_id: '32VK1RT0MF54A', line_item_id: 'MZ2XP27HZ7G4C', amount: 500, discount_name: 'QA-test brand discount' }
		# p = { device_id: '74e6a379-9a1f-4511-ac6c-96e4b54c10b8', order_id: '32VK1RT0MF54A', amount: 5000, tax_amount: 0, note: 'QA - test payment' }

	attr_reader :merchant_id, :auth_token, :h, :tender_id

	RestClient.log = 'stdout' unless Rails.env.production?

	def initialize args={}
		@h = args.stringify_keys!
		@merchant_id = @h['merchant_id'] || @h['pos_merchant_id']
		@auth_token = @h['auth_token']
		@tender_id = nil
	end

#	-------------

	def get_tender_id
		x = get_tender
		x['id']
	end

	def get_tender all=nil
		return get_api ['tenders'] if all
		x = get_api ['tenders'], { filter: "label=ItsOnMe" }
		if x[:data]['elements']
			x[:data]['elements'][0]
		else
			x[:data]
		end
	end

	def get_devices
		return get_api ['devices']
	end

	def get_hours
		return get_api ['opening_hours']
	end

	def get_items
		return get_api ['items']
	end

	def get_order order_id
		return get_api ['orders', order_id]
	end

	def get_order_line_items order_id
		return get_api ['orders', order_id, 'line_items']
	end

	def get_order_line_item order_id, line_item_id
		return get_api ['orders', order_id, 'line_items', line_item_id]
	end

	def get_order_discounts order_id
		return get_api ['orders', order_id, 'discounts']
	end

	def get_order_payments order_id
		return get_api ['orders', order_id, 'payments']
	end


#	-------------


		# MONEY VALUE REDEMPTION
		#	def post_order_payment order_id, device_id, amount, tax_amount, note
	def post_order_payment args={}
		@tender_id = get_tender_id
		args.stringify_keys!
		device_id = args['device_id']
		order_id = args['order_id']
		amount = args['amount']
		tax_amount = (args['tax_amount'] || 0).to_i
		note = args['note'] || ORDER_PAYMENT_NOTE

		if device_id && order_id && amount

			payment_body = { 'order' => { id: order_id },
						'tender' => { id: @tender_id },
						'device' => { id: device_id },
						'amount' => amount,
						'tax_amount' => tax_amount,
						'note' => note
					}
			puts payment_body
			return post_api ['orders', order_id, 'payments'], payment_body
		else
			raise 'OpsCloverApi: Missing required order data'
		end
	end

		# BRAND CARD REDEMPTION
		#	def post_line_item_discount order_id, line_item_id, name, amount
	def post_line_item_discount args={}
		args.stringify_keys!
		order_id = args['order_id']
		line_item_id = args['line_item_id']
		amount = args['amount']
		discount_name = args['discount_name']

		if order_id && line_item_id && amount && discount_name
			discount = { name: discount_name, amount: (-1 * amount) }
			puts discount.inspect
			return post_api ['orders', order_id, 'line_items', line_item_id, 'discounts' ], discount
		end
	end


		#	def reset_auth_token
		##		"https://sandbox.dev.clover.com/oauth/token?client_id={appId}&client_secret={appSecret}&code={codeUrlParam}"
		#		auth_json = get('oauth', "token?client_id=#{CLOVER_APP_ID}&client_secret=#{CLOVER_APP_SECRET})
		#		auth_hash = JSON.parse auth_json
		#		@auth_token = auth_hash['access_token']
		#	end



#	-------------    API CONNECT

	def get_api terms=[], query={}
		return get terms_to_resource(terms, query)
	end

	def post_api terms, body
		return post terms_to_resource(terms, {}), body
	end

	def terms_to_resource terms, query
		terms = [terms] unless terms.kind_of?(Array)
		resource = (['v3/merchants', merchant_id] + terms).join('/')

		query = {} unless query.kind_of?(Hash)
		# resource += query[:order_by].present? ? "?order_by=#{query[:order_by]}" : ''
		resource += query[:filter].present? ? "?filter=#{query[:filter]}" : ''
		return resource
	end

    def get resource

         response = RestClient.get(
            "#{CLOVER_BASE_URL}/#{resource}",
            header
        )

		resp = JSON.parse response
        return { status: 1, data: resp }

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
    	puts 'body=' + body.inspect

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


private


	def header
		{ content_type: :json, accept: :json, 'Authorization' => "Bearer #{@auth_token}" }
	end

end
