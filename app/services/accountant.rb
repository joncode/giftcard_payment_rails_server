class Accountant

	class << self

		def merchant gift
			return nil if gift.class != Gift

			debt_amount = gift.location_fee
			return false unless debt_amount > 0  # no fee , no debt

			check_for = Register.where(gift_id: gift.id, origin: Register.origins["loc"])
			return true if check_for.count > 0   # already loc debt for this gift

			debt_amount = gift.location_fee
			create_debt(gift, gift.provider, debt_amount, "loc")
		end

		def affiliate_location gift
			return nil if gift.class != Gift
			return nil if gift.cat != 300

			loc_affiliation = Affiliation.get_merchant_affiliation_for_gift(gift)
			return loc_affiliation if loc_affiliation.class != Affiliation

			check_for = Register.where(gift_id: gift.id, origin: Register.origins["aff_loc"])
			return true if check_for.count > 0   # already aff_loc debt for this gift

			debt_amount =  ((gift.value.to_f * 100).to_i * 0.15) * 0.1
			create_debt(gift, loc_affiliation.affiliate, debt_amount, "aff_loc")
		end

		def affiliate_user gift
			return nil if gift.class != Gift
			return nil if gift.cat != 300

			user_affiliation = Affiliation.get_user_affiliation_for_gift(gift)
			return user_affiliation if user_affiliation.class != Affiliation

			check_for = Register.where(gift_id: gift.id, origin: Register.origins["aff_user"])
			return true if check_for.count > 0   # already aff_loc debt for this gift

			debt_amount =  ((gift.value.to_f * 100).to_i * 0.15) * 0.1
			create_debt(gift, user_affiliation.affiliate, debt_amount, "aff_user")
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
			reg.save
		end
	end
end