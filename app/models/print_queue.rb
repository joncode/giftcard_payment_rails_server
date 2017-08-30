class PrintQueue < ActiveRecord::Base
	HEX_ID_PREFIX = 'prnt_'

#   -------------

	validates_presence_of :merchant_id

#   -------------

	belongs_to :merchant
	belongs_to :redemption
	has_one :gift , through: :redemption

	delegate :ccy, :amount, to: :redemption, allow_nil: true
	alias_method :applied_value, :amount

	delegate :timezone, :current_time, to: :merchant

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

	# def inspect
	# 	{ 'response' => response, 'request' => make_request_hsh }.to_s
	# end

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

	def set_redeem
		redeemeable? ? update(status: 'done') : false
	end

	def set_cancel
		cancellable? ? update(status: 'cancel') : false
	end

	def redeemeable?
		['queue', 'delivered'].include?(self.status)
	end

	def cancellable?
		['queue', 'delivered'].include?(self.status)
	end

#   -------------

	def self.print_request printer_id
		return nil if !printer_id.kind_of?(String) || printer_id.blank?
		client = ClientUrlMatcher.get_app_key(printer_id)
		if client && client.partner_type == 'Merchant'
			partner = client.partner
			print_queues = where(merchant_id: partner.id, status: 'queue')
			return nil if print_queues.empty?
			return print_queues
		else
			# client is not registered with system
			# alert devs
			return nil
		end
	end

	def self.deliver print_queues
		print_queues = [print_queues] unless print_queues.kind_of?(Array)
		where(id: print_queues.map(&:id)).update_all(status: 'delivered', group: get_unique_group_id)
		to_epson_xml(print_queues)
	end

	def self.to_epson_xml print_queues
		xml = '<?xml version="1.0" encoding="utf-8"?><PrintRequestInfo Version="2.00">'

		print_queues.each do |que|
			xml += que.to_epson_xml
		end
		xml += '</PrintRequestInfo>'

		return xml
	end

#   -------------

	def self.queue_redemption(redemption)
		create(status: 'queue', merchant_id: redemption.merchant_id, type_of: 'redeem', redemption_id: redemption.id )
	end

	def self.queue_test_redemption(merchant)
		create(status: 'queue', merchant_id: merchant.id, type_of: 'test_redeem' )
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

	def get_group
		self.group || self.id
	end

	def to_epson_xml
		case self.type_of
		when 'redeem'
				# how to get the group into this  ??
			redemption.to_epson.xml
		when 'test_redeem'
			PrintTestRedemption.new(get_group, merchant).to_epson_xml
		when 'shift_report'
			PrintShiftReport.new(get_group, merchant).to_epson_xml
		else # help
			PrintHelp.new(get_group, merchant).to_epson_xml
		end
	end

#   -------------

	def set_group
		if self.status == 'delivered' && self.group.nil?
			self.group = get_unique_group_id
		end
	end

end



