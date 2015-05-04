class Accountant

	class << self

		def merchant gift

			return 'Not Gift' if gift.class != Gift
			puts "\n Merchant #{gift.id}\n"

			debt_amount = gift.location_fee

 			# no fee , no debt
			return "no Debt Amount" unless debt_amount > 0

			# if provider is not on creation and gift is not on redemption - out of sync exit
			return "Payment time not in sync" if gift.status != 'redeemed' && !gift.provider.creation?

			# if gift is not a purchase (300), do not pay on anything other than status = redeemed
			return "Not redmption not a purchase" if gift.status != 'redeemed' && gift.cat != 300

			return "Register exists"  if Register.exists?(gift_id: gift.id, origin: Register.origins["loc"])


			register = create_debt(gift, gift.provider.merchant, "loc")
			if register.save
				return register.inspect
			else
				return register.errors.messages
			end
		end

		def affiliate_location gift
			return nil if gift.class != Gift
			puts "\n Affiliate affiliate_location #{gift.id}\n"
			return nil if gift.cat   != 300

			loc_affiliation = Affiliation.get_merchant_affiliation_for_gift(gift)
			return loc_affiliation if loc_affiliation.class != Affiliation

			return true if Register.exists?(gift_id: gift.id, origin: Register.origins["aff_loc"])

			register    = create_debt(gift, loc_affiliation.affiliate, "aff_loc")
			register.partner     = loc_affiliation.affiliate
			register.affiliation = loc_affiliation
			register.save
		end

		def affiliate_user gift
			return nil if gift.class != Gift
			puts "\n Affiliate affiliate_user #{gift.id}\n"
			return nil if gift.cat   != 300

			user_affiliation = Affiliation.get_user_affiliation_for_gift(gift)
			return user_affiliation if user_affiliation.class != Affiliation

			return true if Register.exists?(gift_id: gift.id, origin: Register.origins["aff_user"])

			register    = create_debt(gift, user_affiliation.affiliate, "aff_user")
			register.partner     = user_affiliation.affiliate
			register.affiliation = user_affiliation
			register.save
		end

		def affiliate_link gift, link
			return nil if gift.class != GiftSale
			puts "\n Affiliate affiliate_link #{gift.id} #{link}\n"
	        lp = LandingPage.where(link: link).first
	        if lp.nil?
	        	lp = LandingPage.click(link: link)
	        end
            lp.gifts += 1
            gift.landing_pages << lp
            register  = create_debt(gift, lp.affiliate, "aff_link")
            register.partner = lp.affiliate
			register.save
            gift.affiliates << lp.affiliate
            lp.save
		end

	private

		def debt_amount gift, origin
			if origin == "loc"
				gift.location_fee.to_i
			else
				(gift.value_in_cents * 0.15 * 0.1).to_i
			end
		end

		def create_debt(gift, obj, origin)
			reg = Register.new
			reg.partner_type = obj.class.to_s
			reg.partner_id   = obj.id
			reg.type_of      = "debt"
			reg.origin       = origin
			reg.gift_id      = gift.id
			reg.amount       = debt_amount(gift, origin)
			reg.gift         = gift
			reg
		end
	end
end