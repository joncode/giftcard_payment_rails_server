class Accountant

	class << self

		def merchant gift

			return 'Not Gift' if gift.class != Gift
			puts "\n Merchant #{gift.id}\n"

			debt_amount = gift.location_fee

 			# no fee , no debt
			return "no Debt Amount" unless debt_amount > 0

			# if provider is not on creation and gift is not on redemption - out of sync exit
			return "Payment time not in sync" if gift.status != 'redeemed' && !gift.merchant.creation?

			# if gift is not a purchase (300), do not pay on anything other than status = redeemed
			return "Not redemption not a purchase" if gift.status != 'redeemed' && gift.cat != 300

			return "Register exists" if gift_parent_has_been_paid? gift

			register = create_debt(gift, gift.merchant, "loc")
			if register.save
				return register
			else
				return register.errors.messages
			end
		end

		def gift_parent_has_been_paid?(gift)
			if get_register_for_merchant gift.id
				return true
			else
				parent = gift.parent
				if !parent.nil? && parent.kind_of?(Gift)
					gift_parent_has_been_paid?(parent)
				else
					return false
				end
			end
		end

		def get_register_for_merchant gift_id
			Register.exists?(gift_id: gift_id, origin: Register.origins["loc"])
		end

		def affiliate_location gift
			return nil if gift.class != Gift
			puts "\n Affiliate affiliate_location #{gift.id}\n"
			return nil if gift.cat   != 300

			loc_affiliation = Affiliation.get_merchant_affiliation_for_gift(gift)
			return loc_affiliation if loc_affiliation.class != Affiliation

			return true if Register.exists?(gift_id: gift.id, origin: Register.origins["aff_loc"])

			register    = create_debt(gift, loc_affiliation.affiliate, "aff_loc")
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
            # binding.pry
            if lp.affiliate.present?
	            register  = create_debt(gift, lp.affiliate, "aff_link")
				register.save
	            gift.affiliates << lp.affiliate
	            lp.save
	        end
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
			# binding.pry
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