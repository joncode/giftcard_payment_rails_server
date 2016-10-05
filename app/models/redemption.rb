class Redemption < ActiveRecord::Base
	include MoneyHelper

#   -------------

    before_validation :set_unique_hex_id, on: :create
    before_validation :set_unique_token, on: :create

#   -------------

	belongs_to :gift
	belongs_to :client

#   -------------

	if Rails.env.staging?
	    # validates_with RedemptionTotalValueValidator
	end

#   -------------

	enum type_of: [ :pos, :v2, :v1, :paper, :zapper ]


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
	        	r.type_of = self.convert_r_sys_to_type_of(Merchant.where(id: loc_id).pluck(:r_sys).first)
        	else
        		r.type_of = self.convert_r_sys_to_type_of(gift.merchant.r_sys)
	        end
        else
	        r.type_of = self.convert_r_sys_to_type_of(r_sys)
        end
        r
	end

	def serialize
		self.serializable_hash except: [ :active ]
	end

#   -------------

	attr_accessor :ccy
	def ccy
		@ccy || self.gift.ccy
	end

	def amount_words(currency=nil)
		if currency.nil?
			currency = ccy
		end
		cents_to_words(self.amount, currency)
	end

    def response
        self.resp_json
    end

    def request
        self.req_json
    end

#   -------------

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

	def set_unique_token
		self.token = UniqueIdMaker.four_digit_token(self.class, :hex_id, { status: 'pending', active: true })
		self.new_token_at = DateTime.now.utc
	end

    def set_unique_hex_id
        self.hex_id = UniqueIdMaker.eight_digit_hex(self.class, :hex_id)
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

