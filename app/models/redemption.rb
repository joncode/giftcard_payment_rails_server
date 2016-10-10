class Redemption < ActiveRecord::Base
	include RedeemHelper
	include MoneyHelper

	# STATUS ENUM : 'pending', 'done', 'expired'
	enum type_of: [ :pos, :v2, :v1, :paper, :zapper ]

    default_scope -> { where(active: true) } # indexed

#   -------------

    before_validation :set_unique_hex_id, on: :create
    before_validation :set_unique_token, on: :create
    before_validation :set_r_sys

#   -------------

	validates_presence_of :gift_id, :r_sys, :amount, :token, :hex_id, :merchant_id

#   -------------

    before_save :set_response_at

#   -------------

	belongs_to :client
	belongs_to :gift
	belongs_to :merchant

#   -------------

	if Rails.env.staging?
	    # validates_with RedemptionTotalValueValidator
	end

#   -------------

    def stale?
    	return true if new_token_at.nil?
    	answer = (new_token_at < reset_time)
    	if answer && status == 'pending'
    		update_column :status, 'expired'
    	end
    	return answer
    end

    def fresh?
    	!stale?
    end
    alias_method :token_fresh?, :fresh?

	def redeemable?
		if r_sys == 2 || type_of == Redemption.convert_r_sys_to_type_of(2).to_s
			status == 'pending' && fresh?
		else
			status == 'pending'
		end
	end

#   -------------

    def paper_id
        @paper_id ||= set_paper_id
    end

    def set_paper_id
        hx = hex_id.gsub('_', '-').upcase
        hx[0..6] + '-' + hx[7..10]
    end

    def self.paper_to_hex paper_id
        hex_id = paper_id[0..6] + paper_id[8..11]
        hex_id.gsub('-','_').downcase
    end

    def self.find_paper paper_id
        where(hex_id: paper_to_hex(paper_id)).first
    end

#   -------------

	attr_accessor :ccy
	def ccy
		@ccy || gift.ccy
	end

	def amount_words(currency=nil)
		if currency.nil?
			currency = ccy
		end
		cents_to_words(amount, currency)
	end

    def response
        resp_json
    end

    def request
        req_json
    end

    def generic_response
		{ "response_code" => apply_code, "response_text"=>{"amount_applied" => amount, 'previous_gift_balance' => gift_prev_value,
			'remaining_gift_balance' => gift_next_value, 'msg' => msg } }
    end

    def apply_code
    	if gift_next_value == 0
    		"PAID"
    	else
    		"APPLIED"
    	end
    end

    def message
    	if status == 'done'
	    	response_at = Time.now.utc if response_at.nil?
	    	"#{display_money(cents: amount, ccy: self.ccy)} was paid on #{TimeGem.change_time_to_zone(response_at, merchant.zone).to_formatted_s(:merchant_date)}"
	   		"#{display_money(cents: amount, ccy: ccy)} was paid with check # #{ticket_id}\n"
	   	end
    end

    def msg
    	str = ticket_id.present? ? "(#{ticket_id})" : ''
    	if gift_next_value == 0
    		"#{display_money(cents: amount, ccy: ccy)} was applied #{str}. Gift has been fully used."
    	else
	    	"#{display_money(cents: amount, ccy: ccy)} was applied #{str}. #{display_money(cents: gift_next_value, ccy: ccy)} remains on the gift."
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
		serializable_hash except: [ :active, :client_id ]
	end


#   -------------

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

	def self.convert_type_of_to_r_sys(typ)
		case typ.to_s
		when 'pos'
			3
		when 'v1'
			1
		when 'v2'
			2
		when 'paper'
			4
		when 'zapper'
			5
		end
	end

	def self.convert_r_sys_to_type_of(r_sys)
		return r_sys if [ :pos, :v2, :v1, :paper, :zapper ].include?(r_sys)
		case r_sys.to_i
		when 1
			:v1
		when 2
			:v2
		when 3
			:pos
		when 4
			:paper
		when 5
			:zapper
		end
	end

#   -------------

	def set_response_at
		if status == 'done' && response_at.nil?
			response_at == DateTime.now.utc
		end
	end

	def set_r_sys
		r_sys = Redemption.convert_type_of_to_r_sys(type_of) if r_sys.nil?
	end

	def set_unique_token
		token = UniqueIdMaker.four_digit_token(Redemption, :hex_id, { status: 'pending', active: true })
		new_token_at = DateTime.now.utc
	end

    def set_unique_hex_id
        hex_id = UniqueIdMaker.eight_digit_hex(Redemption, :hex_id, 'rd_')
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

