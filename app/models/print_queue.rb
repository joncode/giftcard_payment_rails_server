class PrintQueue < ActiveRecord::Base
	HEX_ID_PREFIX = 'pt_'

	default_scope -> { order(:created_at) }

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

	before_save :set_job
	before_save :set_redemption

#   -------------   POS API SURFACE METHODS

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

	def self.cancel_stale_delivered
		send_fail_msg = false
		pqs = where(status: 'delivered').where('updated_at < ?', 20.minutes.ago)
		pqs.each do |pq|
			reason = { success: "false", code: "IOM_SYS_NO_RESPONSE", msg: "PrintQueue Delivered on #{pq.updated_at}. No response from Printer. Print Job cancelled #{DateTime.now.utc}" }
			pq.update(status: 'cancel', reason: reason)
			send_fail_msg = true
		end
		if send_fail_msg
			OpsTwilio.text_devs(msg: "Cancel stale deivered print queues #{pqs[0].inspect}")
		end
	end


	def self.get_merchant_for_client_id printer_id
		return nil if !printer_id.kind_of?(String) || printer_id.blank?
		client = ClientUrlMatcher.get_app_key(printer_id)
		if client && client.partner_type == 'Merchant'
			return client.partner
		else
			puts "500 Internal - Epson Client is matched with nothing OR affiliate - client_id = #{printer_id}"
			return nil
		end
	end

	def self.print_request printer_id
		if merchant = get_merchant_for_client_id(printer_id)
			print_queues = where(merchant_id: merchant.id, status: 'queue')
			return nil if print_queues.empty?
			return print_queues
		else
			# client is not registered with system
			# alert devs
			return nil
		end
	end

	def self.deliver print_queues
		print_queues = [print_queues] unless (print_queues.is_a?(Array) || print_queues.is_a?(ActiveRecord::Relation))
			# the redemption ID is not the same as this print job ID
		print_queues.each do |pq|
			pq.status = 'delivered'
			pq.save
		end
		to_epson_xml(print_queues)
	end

	def self.to_epson_xml print_queues
		print_queues = [print_queues] unless print_queues.respond_to?(:each)
		xml = '<?xml version="1.0" encoding="utf-8"?><PrintRequestInfo Version="2.00">'

		print_queues.each do |que|
			xml += que.to_epson_xml
		end
		xml += '</PrintRequestInfo>'

		return xml
	end

	def to_epson_xml
		case self.type_of
		when 'redeem'
				# how to get the job into this  ??
			redemption.to_epson_xml
		when 'test_redeem'
			PrintTestRedemption.new(merchant, nil, redemption).to_epson_xml
		when 'shift_report'
			PrintShiftReport.new(merchant, get_job).to_epson_xml
		else # help
			PrintHelp.new(merchant, get_job).to_epson_xml
		end
	end

	def get_job
		self.job
	end

#   -------------

	def self.mark_job status_str, client_id, job, msg=nil
			# DO I NEED THE CLIENT ID FOR THIS ? GROUPS ARE UNIQUE
		if merchant = get_merchant_for_client_id(client_id)
			if job.to_s.match(/XX-/)
				# test redemptions
				pqs = where(merchant_id: merchant.id, type_of: 'test_redeem')
			else
				pqs = where(job: job, merchant_id: merchant.id)
			end
			pqs.map do |pq|
				pq.status = status_str
				pq.reason = msg
				pq.save
				pq
			end
		else
			return []
		end
	end

	def self.mark_job_as_error client_id, job, msg=nil
		puts "PrintQueue (143) #{client_id} #{job} #{msg}"
		mark_job 'cancel', client_id, job, msg
	end

	def self.mark_job_as_printed client_id, job
		puts "PrintQueue (147) #{client_id} #{job}"
		pqs = mark_job('done', client_id, job)
		pqs.each do |pq|
			if pq.type_of == 'redeem' && pq.status == 'done'
				if pq.redemption.status == 'pending'
					resp = Redeem.complete_redeem(redemption: pq.redemption, client_id: client_id)
				else
					puts "PrintQueue (147) - 500 Internal - redemption sync issues #{pq.id}"
				end
			end
		end
	end

#   -------------

	def self.new_print_queue(redemption)
		create(status: 'queue', job: redemption.hex_id, merchant_id: redemption.merchant_id,
				type_of: 'redeem', redemption_id: redemption.id )
	end

	def self.queue_redemption(redemption)
		# check for previous print queue and re-print if cancel
		pq = where(job: redemption.hex_id, merchant_id: redemption.merchant_id, type_of: 'redeem', redemption_id: redemption.id ).first_or_create
		case pq.status
		when 'queue'
			return pq
		when 'delivered'
			# less then 10 minutes
			return pq if pq.created_at > 10.minutes.ago
			# more then 10 minutes
			# cancel print job and queue one
			pq.update(status: 'cancel')
			return new_print_queue(redemption)
		when 'done'
			return pq
		else # cancel / expired
			# make a new print queue
			return new_print_queue(redemption)
		end
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

	def self.get_unique_job_id
		UniqueIdMaker.eight_digit_hex(self, :job, HEX_ID_PREFIX)
	end

	def set_job
		if self.job.blank?
			if redemption
				self.job = redemption.hex_id
			else
				self.job = PrintQueue.get_unique_job_id
			end
		end
	end

	def set_redemption
		# redemption must be set to complete when print_queue is set to done
		# redemption must be cancelled if print queue is cancelled
		# redemption must be expired when print queue is expired , should this be reversed ?
	end

end



