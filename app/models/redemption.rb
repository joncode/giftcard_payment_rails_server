class Redemption < ActiveRecord::Base

	belongs_to :gift

#   -------------

	if Rails.env.staging?
	    # validates_with RedemptionTotalValueValidator
	end

#   -------------

    def response
        JSON.parse self.resp_json
    rescue
        nil
    end

    def request
        JSON.parse self.req_json
    rescue
        nil
    end

#   -------------

	enum type_of: [ :pos, :v2, :v1, :paper, :zapper ]

	def self.init_with_gift(gift, loc_id=nil, r_sys=nil)
        r = Redemption.new
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

	def self.convert_r_sys_to_type_of(r_sys)
		return r_sys if [ :pos, :v2, :v1, :paper, :zapper ].include?(r_sys)
		case r_sys
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

