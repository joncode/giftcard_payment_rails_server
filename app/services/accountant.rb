class Accountant

	class << self

		def merchant gift
			return nil if gift.class != Gift

			debt_amount = gift.location_fee
			return false unless debt_amount > 0  # no fee , no debt

			return true if Register.exists?(gift_id: gift.id, origin: Register.origins["loc"])

			debt_amount = gift.location_fee
			register    = create_debt(gift, gift.provider.merchant, debt_amount, "loc")
			register.save
		end

		def affiliate_location gift
			return nil if gift.class != Gift
			return nil if gift.cat   != 300

			loc_affiliation = Affiliation.get_merchant_affiliation_for_gift(gift)
			return loc_affiliation if loc_affiliation.class != Affiliation

			return true if Register.exists?(gift_id: gift.id, origin: Register.origins["aff_loc"])

			debt_amount =  ((gift.value.to_f * 100).to_i * 0.15) * 0.1
			register    = create_debt(gift, loc_affiliation.affiliate, debt_amount, "aff_loc")
			register.partner     = loc_affiliation.affiliate
			register.affiliation = loc_affiliation
			register.save
		end

		def affiliate_user gift
			return nil if gift.class != Gift
			return nil if gift.cat   != 300

			user_affiliation = Affiliation.get_user_affiliation_for_gift(gift)
			return user_affiliation if user_affiliation.class != Affiliation

			return true if Register.exists?(gift_id: gift.id, origin: Register.origins["aff_user"])

			debt_amount =  ((gift.value.to_f * 100).to_i * 0.15) * 0.1
			register    = create_debt(gift, user_affiliation.affiliate, debt_amount, "aff_user")
			register.partner     = user_affiliation.affiliate
			register.affiliation = user_affiliation
			register.save
		end

	private

		def create_debt(gift, obj, debt_amount, origin)
			reg = Register.new
			reg.partner_type = obj.class.to_s
			reg.partner_id   = obj.id
			reg.type_of      = "debt"
			reg.origin       = origin
			reg.gift_id      = gift.id
			reg.amount       = debt_amount.to_i
			reg
		end
	end
end