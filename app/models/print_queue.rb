class PrintQueue < ActiveRecord::Base
	HEX_ID_PREFIX = 'prnt_'

#   -------------

	belongs_to :merchant
	belongs_to :redemption
	has_one :gift , through: :redemption

	delegate :ccy, :amount, to: :redemption
	alias_method :applied_value, :amount

#   -------------

	before_save :set_group

#   -------------

	# {
	# 	id: _id,
	# 	merchant_id: _id,
	# 	target_id: _id,
	# 	type: [ :redeem, :shift_report, :help ],
	# 	printer_type: 'epson', default: :epson,
	# 	status: [ :queue, :delivered, :done, :cancel], default: :queue
	# }

	# :success?, :ticket_id, :response, :make_request_hsh, :applied_value

	def inspect
		{ 'response' => response, 'request' => make_request_hsh }.to_s
	end

	def make_request_hsh
		{
			"print_queue_id" => self.id,
            "gift_card_id" => gift.hex_id,
            "value" => redemption.amount,
            "ccy" => redemption.ccy,
            'redemption_id' => redemption.hex_id
        }
	end

	def success?
		persisted?
	end

	def ticket_id
		self.id
	end

	def response
    	if success?
    		status = redemption.status
    		redemption.status = 'done'
			h = { "success" => success?, "response_code" => 'APPLIED', "response_text"=> { "amount_applied" => applied_value, 'msg' => redemption.msg }, 'api' => { 'system' => 'PrintQueue'} }
			redemption.status = status
			h
		else
			{ "success" => success?, "response_code" => "ERROR", "response_text"=> { "amount_applied" => 0, 'msg' => 'PrintQueue unavailable' }, 'api' => { 'system' => 'PrintQueue'} }
		end
	end

#   -------------

	def self.print_request printer_id
		return nil if !printer_id.kind_of?(String) || printer_id.blank?
		client = ClientUrlMatcher.get_app_key(printer_id)
		if client
			partner = client.partner
			items = where(partner: partner, status: 'queue')
			return nil if items.empty?
			return items
		else
			# client is not registered with system
			# alert devs
			return nil
		end
	end

	def self.deliver items
		items = [items] unless items.kind_of?(Array)
		where(id: items.map(&:id)).update_all(status: 'delivered', group: get_unique_group_id)
		to_epson_xml(items)
	end

	def self.to_epson_xml items
		xml = '<?xml version="1.0" encoding="utf-8"?><PrintRequestInfo Version="2.00">'

		items.each do |item|
			xml += item.to_epson_xml
		end
		xml += '</PrintRequestInfo>'

		return xml
	end

#   -------------

	def self.queue_redemption(redemption)
		create(status: 'queue', merchant_id: redemption.merchant_id, type_of: 'redeem', redemption_id: redemption.id )
	end

	def self.queue_shift(merchant)
		create(status: 'queue', merchant_id: merchant.id, type_of: 'shift_report' )
	end

	def self.queue_help(merchant)
		create(status: 'queue', merchant_id: merchant.id, type_of: 'help' )
	end

#   -------------

	def get_unique_group_id
		UniqueIdMaker.eight_digit_hex(self.class, :group, self.class.const_get(:HEX_ID_PREFIX))
	end

	def set_group
		if self.status == 'delivered' && self.group.nil?
			self.group = get_unique_group_id
		end
	end


end



