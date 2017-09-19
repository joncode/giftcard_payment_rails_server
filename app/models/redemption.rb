class Redemption < ActiveRecord::Base
	HEX_ID_PREFIX = 'rd_'
	include HexIdMethods
	include RedeemHelper
	include MoneyHelper
	include EpsonXmlHelper

	# STATUS ENUM : 'pending', 'done', 'expired'
	enum type_of: [ :omnivore, :v2, :v1, :paper, :zapper, :admin, :clover, :epson ]

    default_scope -> { where(active: true) } # indexed - # do NOT remove !@
    scope :live_scope, -> (gift) { where(gift_id: gift.id, status: ['done', 'pending']).order(created_at: :desc) }
    scope :pending_scope, -> (gift) { where(gift_id: gift.id, status: 'pending').order(created_at: :desc) }
    scope :get_live_scope, -> { where(status: ['done', 'pending']).order(created_at: :desc) }

    scope :done_for_merchant_in_range, -> (merchant, range) { where(merchant_id: merchant.id, created_at: range, status: 'done') }


    delegate :ccy, :giver_name, :receiver_name, to: :gift
	delegate :timezone, :current_time, to: :merchant, allow_nil: true
	def redemption_time
		 self.current_time(self.response_at).to_datetime.to_formatted_s(:time)
	end
	delegate :name,:address, prefix: :merchant, to: :merchant, allow_nil: true

#   -------------

    before_validation :set_unique_token, on: :create
    before_validation :set_r_sys

#   -------------

	validates_presence_of :gift_id, :r_sys, :amount, :token, :merchant_id

#   -------------

    before_save :set_request_at
    before_save :set_response_at

    after_commit :remove_token_from_gift

#   -------------


	belongs_to :client
	belongs_to :gift, autosave: true
	belongs_to :merchant

	has_many :print_queues

	def gift
 		@gift ||= Gift.unscoped.where(id: self.gift_id).first
	end

    def brand_card_ids
        return gift.brand_card_ids
	rescue
		return []
    end

#   -------------


	def self.expire_stale_tokens
		where(status: 'pending').find_each do |redemption|
			redemption.stale?
		end
	end

	def redeemable?
		return false if self.status != 'pending'
		fresh?
	end

    def fresh?
    	!stale?
    end
    alias_method :token_fresh?, :fresh?

    def stale?
		if self.new_token_at.nil?
			OpsTwilio.text_devs msg: "Redemption #{self.id} has no :new_token_at  - BAD DATA"
			boolean = true
		else
			case self.r_sys
			when 1		# synchronous, so should be immediate
						# 5 minutes
				boolean = self.new_token_at < 5.minutes.ago
			when 2 		# v2 MerchantTools tablet
						# token lasts for 24 hours
				boolean = self.new_token_at < 24.hours.ago
			when 3 		# omnivore
						# 27 seconds
				boolean = self.new_token_at < 5.minutes.ago
			when 4  	# paper certificate
						# does not expire
				boolean = false
			when 5 		# zapper
						# 3 minutes
				boolean = self.new_token_at < 10.minutes.ago
			when 6		# admin
						# 10 minutes
				boolean = self.new_token_at < 10.minutes.ago
			when 7 		# Clover POS
						# token lasts for 4 hours
				boolean = self.new_token_at < 4.hours.ago
			when 8		# Epson Printer
						# token last for 2 minutes - time for printer poll to be processed
				boolean = self.new_token_at < 200.minutes.ago
			else
						# ERROR !
				OpsTwilio.text_devs msg: "Redemption #{self.id} has unknown R-sys = |#{self.r_sys}|"
				boolean = true
			end
		end
		if boolean && self.status == 'pending'
				# status is out of sync with token , redemption must be expired
			remove_pending('expired', { 'response_code' => 'SYSTEM_EXPIRE', 'response_text' => "API Redemption :stale? - Token #{self.token} stale #{Time.now.utc} - #{self.new_token_at}" })
		end
		return boolean
    end

    def expires_at
    	return nil if self.new_token_at.nil?
		case self.r_sys
		when 1		# synchronous, so should be immediate
					# 5 minutes
			self.new_token_at + 5.minutes
		when 2 		# v2 MerchantTools tablet
					# token lasts for 24 hours
			self.new_token_at + 24.hours
		when 3 		# omnivore
					# 27 seconds
			self.new_token_at + 5.minutes
		when 4  	# paper certificate
					# does not expire
			nil
		when 5 		# zapper
					# 3 minutes
			self.new_token_at + 10.minutes
		when 6		# admin
					# 10 minutes
			self.new_token_at + 10.minutes
		when 7 		# Clover POS
					# token lasts for 4 hours
			self.new_token_at + 4.hours
		when 8		# Epson Printer
					# token last for 2 minutes - time for printer poll to be processed
			self.new_token_at + 200.minutes
		else
					# ERROR !
			nil
		end
    end

	def remove_pending cancel_type, response
		return nil if self.status != 'pending'
		return nil unless ['expired', 'cancel', 'failed'].include?(cancel_type)
		self.status = cancel_type
		self.response = response
		self.gift_next_value = self.gift_prev_value
		if save
			gift = self.gift
			if gift
				Redeem.set_gift_current_balance_and_status(gift)
				gift.save
			end
		end
	end

	def run_operation operation
		if operation == 'cancel'
			return remove_pending('cancel', { 'response_code' => 'API_SYSTEM_EXPIRE', 'response_text' => "API run_opertion cancel" })
		end
		case operation.type_of
		when 'complete'
			if self.status == 'pending'
				remove_pending('done', { 'response_code' => 'API_SYSTEM_REDEEM', 'response_text' => "API run_opertion completed" })
			end
		when 'cancel'
			if self.status == 'pending'
				remove_pending('cancel', { 'response_code' => 'API_SYSTEM_EXPIRE', 'response_text' => "API run_opertion cancel" })
			end
		when 'unredeem'
			if self.status == 'done'
				unredeem({ 'response_code' => 'API_SYSTEM_UNREDEEM', 'response_text' => "API run_opertion unredeem" })
			end
		when 'deactivate'
			toggle_active
		when 'activate'
			toggle_active
		else
			false
		end
	end

	def toggle_active
		if toggle!(:active)
			msg = "Active set to #{self.active} on #{DateTime.now.utc}"
		else
			msg = "Could not set active"
		end
		if self.response.nil?
			self.response = { 'toggle_active' => msg  }
		else
			self.response['toggle_active'] = response
		end
	end

#   -------------

	def amount_words(currency=nil)
		currency = ccy if currency.nil?
		cents_to_words(self.amount, currency)
	end

	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
	end

#   -------------

    def response
        self.resp_json
    end

    def response= obj
		if self.resp_json.nil?
			self.resp_json = obj
		else
			hsh = obj
			hsh[self.response_at.to_s] = self.resp_json
			self.resp_json = hsh
			self.response_at = nil
		end
    end

    def request
        self.req_json
    end

    def request= obj
		if self.req_json.nil?
			self.req_json = obj
		else
			hsh = obj
			hsh[self.request_at.to_s] = self.req_json
			self.req_json = hsh
			self.request_at = nil
		end
    end

#   -------------

	def success_hsh
		{
            previous_gift_balance: self.gift_prev_value,
            amount_applied: self.amount,
            remaining_gift_balance: self.gift_next_value,
            msg: "Give code #{self.token} to your server"
		}
	end

    def generic_response
    	if ['pending', 'done'].include?(self.status)
			{ "response_code" => apply_code, "response_text"=>{"amount_applied" => self.amount, 'previous_gift_balance' => self.gift_prev_value,
				'remaining_gift_balance' => self.gift_next_value, 'msg' => msg } }
		else
			{ "response_code" => apply_code, "response_text"=>{"amount_applied" => 0, 'previous_gift_balance' => self.gift_prev_value,
				'remaining_gift_balance' => self.gift_prev_value, 'msg' => msg } }
		end
    end

    def apply_code
    	if self.status == 'done'
	    	if self.amount == 0
	    		"ERROR"
	    	elsif self.gift_next_value == 0
	    		"PAID"
	    	else
	    		"APPLIED"
	    	end
	    else
	    	self.status.upcase
	    end
    end

    def message
    	if status == 'done'
	    	self.response_at = Time.now.utc if response_at.nil?
	    	"#{display_money(cents: self.amount, ccy: ccy)} was paid on #{TimeGem.change_time_to_zone(self.response_at, merchant.zone).to_formatted_s(:merchant_date)}"
	   		"#{display_money(cents: self.amount, ccy: ccy)} was paid with check # #{self.ticket_id}\n"
	    else
		   	"Redemption is #{apply_code}"
	    end
    end

    def msg
    	if status == 'done'
	    	str = ticket_id.present? ? "(#{ticket_id})" : ''
	    	if self.gift_next_value == 0
	    		"#{display_money(cents: amount, ccy: ccy)} was applied #{str}. Gift has been fully used."
	    	else
		    	"#{display_money(cents: amount, ccy: ccy)} was applied #{str}. #{display_money(cents: self.gift_next_value, ccy: ccy)} remains on the gift."
		    end
	    else
		   	"Redemption is #{apply_code}"
	    end
    end

#   -------------

	def self.init_with_gift(gift, loc_id=nil, r_sys=nil)
        r = new
        r.gift_id = gift.id
        r.amount          = gift.value_cents
        r.gift_prev_value = gift.value_cents
        r.gift_next_value = 0
        r.ticket_id       = nil
        r.merchant_id = loc_id || gift.merchant_id
        if r_sys.nil?
        	if loc_id.present? && loc_id != gift.merchant_id
	        	r.type_of = convert_r_sys_to_type_of(Merchant.where(id: loc_id).pluck(:r_sys).first)
        	else
        		r.type_of = convert_r_sys_to_type_of(gift.merchant.r_sys)
	        end
        else
	        r.type_of = convert_r_sys_to_type_of(r_sys)
        end
        r
	end

	def serialize
		h = serializable_hash except: [ :active, :client_id ]
		if self.status == 'pending'
			h[:expires_at] = expires_at
		end
		h
	end


#   -------------


	def self.current_paper gift
		where(gift_id: gift.id, r_sys: 4, status: 'pending', active: true).order(created_at: :desc)
	end

	def self.get_all_live_redemptions gift, r_sys=nil
		if r_sys.nil?
			live_scope(gift)
		else
			live_scope(gift).where(r_sys: r_sys)
		end
	end

	def self.current_pending_redemption gift, redeems=nil, r_sys=nil
		if redeems.nil?
			if r_sys.nil?
				redeems = pending_scope(gift)
			else
				redeems = pending_scope(gift).where(r_sys: r_sys)
			end
		end
		redemption = nil
		redeems.each do |redeem|
			if redeem.status == 'pending'
				if redeem.stale?
					# expire and skip
					next
				else
					if (gift.balance == redeem.amount) || (gift.original_value == redeem.amount)
						# full redemption - no more redemptions allowed
						puts "Redemption FOUND #{redeem.id}"
						redemption = redeem
						break
					else
						# pending exists but we could make another, what are criteria ?
						puts "Redemption FOUND (partial) #{redeem.id}"
						redemption = redeem
						break
					end
				end
			end
		end
		return redemption
	end

	def self.get_epson_printable_redemption merchant
		where(r_sys: 8, merchant_id: merchant.id, status: 'pending').first
	end

	def self.get_for_partner partner, start_datetime=nil, end_datetime=nil
		return [] if !partner.respond_to?(:id)
		end_datetime = DateTime.now.utc if end_datetime.nil?
		start_datetime = (end_datetime - 1.year) if start_datetime.nil?
		if partner.kind_of?(Affiliate)

			query = "select r.*, m.name AS merchant_name FROM redemptions r, gifts g, affiliates a, merchants m \
WHERE g.partner_type = '#{partner.class.to_s}' AND g.partner_id = a.id AND r.gift_id = g.id AND a.id = #{partner.id} \
AND g.status = 'redeemed' AND m.id = r.merchant_id AND \
r.created_at >= '#{start_datetime}' AND r.created_at < '#{end_datetime}' \
ORDER BY created_at desc"

			return find_by_sql(query)
		else
			return where(merchant_id: partner.id, created_at: start_datetime ... end_datetime).order(created_at: :desc).to_a
		end
	end

	def self.count_promo_redemptions_for(partner, start_date, end_date)
        redemptions = promo_redemptions_for(partner, start_date, end_date)
        redemptions.length
	end

	def self.total_promo_redemptions_for(partner, start_date, end_date)
		#- which returns an integer of cents redeemed in time period
        redemptions = promo_redemptions_for(partner, start_date, end_date)
        redemptions.map(&:amount).sum
	end

	def self.promo_redemptions_for(partner, start_date, end_date)
		if partner.kind_of?(Affiliate)
			specifc_query = "g.merchant_id = m.id AND m.affiliate_id = #{partner.id}"
			setup_vars = ", merchants m "
		else
			specifc_query = "g.merchant_id = #{partner.id}"
			setup_vars = ''
		end

		query = "SELECT r.* FROM redemptions r, gifts g #{setup_vars} \
WHERE (g.cat >=  200 AND g.cat <  300) AND r.gift_id = g.id AND g.status = 'redeemed' AND r.status = 'done' \
AND #{specifc_query} AND (r.created_at >= '#{start_date}' AND r.created_at < '#{end_date}')"
        find_by_sql(query)
	end


#   -------------


	def self.get_multi_with_token token, mids
		where(token: token, merchant_id: mids, status: ['pending', 'done'])
	end

	def self.get_multi_with_hex_id hex_id, mids
		where(hex_id: hex_id, merchant_id: mids, status: ['pending', 'done'])
	end


#   -------------


	def self.convert_type_of_to_r_sys(typ)
		case typ.to_s
		when 'v1'
			1
		when 'v2'
			2
		when 'omnivore'
			3
		when 'paper'
			4
		when 'zapper'
			5
		when 'admin'
			6
		when 'clover'
			7
		when 'epson'
			8
		end
	end

	def self.convert_r_sys_to_type_of(r_sys)
		return r_sys if type_ofs.symbolize_keys.keys.include?(r_sys)
		case r_sys.to_i
		when 1
			:v1
		when 2
			:v2
		when 3
			:omnivore
		when 4
			:paper
		when 5
			:zapper
		when 6
			:admin
		when 7
			:clover
		when 8
			:epson
		end
	end

#   -------------

	def set_response_at
		if self.resp_json.present? && self.response_at.nil?
			self.response_at = DateTime.now.utc
		end
	end

	def set_request_at
		if self.req_json.present? && self.request_at.nil?
			self.request_at = DateTime.now.utc
		end
	end

	def set_r_sys
		self.r_sys = Redemption.convert_type_of_to_r_sys(self.type_of) if self.r_sys.nil?
	end

	def set_unique_token
		self.token = UniqueIdMaker.four_digit_token(Redemption, :token, { status: 'pending', active: true })
		self.new_token_at = DateTime.now.utc
	end

    def remove_token_from_gift
    	if self.status != 'pending' && self.r_sys == 2
    		g = self.gift
    		if g.token == self.token && g.status == 'notified'
    			g.token == nil
    			g.new_token_at = nil
    			g.save
			end
    	end
    end

end

# == Schema Information
#
# Table name: redemptions
#
#  id              :integer         not null, primary key
#  gift_id         :integer
#  amount          :integer         default(0)
#  ticket_id       :string(255)
#  req_json        :json
#  resp_json       :json
#  type_of         :integer         default(0)
#  gift_prev_value :integer         default(0)
#  gift_next_value :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

