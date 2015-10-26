class Redemption < ActiveRecord::Base

	belongs_to :gift

#   -------------

	enum type_of: [ :positronics, :v2, :v1 ]

	def self.init_with_gift(gift, loc_id=nil, r_type_of=nil)
        r = Redemption.new
        r.gift_id = gift.id
        r.amount          = gift.value_in_cents
        r.gift_prev_value = gift.value_in_cents
        r.gift_next_value = 0
        r.ticket_id       = nil
        r.merchant_id = loc_id || gift.merchant_id
        if r_type_of.nil?
        	if loc_id == gift.merchant_id
        		r.type_of = self.convert_r_sys_to_type_of(gift.merchant.r_sys)
        	else
	        	r.type_of = self.convert_r_sys_to_type_of(Merchant.where(id: loc_id).pluck(:r_sys).first)
	        end
        else
	        r.type_of = r_type_of
        end
        r
	end

	def self.convert_r_sys_to_type_of(r_sys)
		case r_sys
		when 1
			:v1
		when 2
			:v2
		when 3
			:positronics
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

