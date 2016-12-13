class Accountant

	# ASSUMPTIONS
		# when a merchant is on redemption, a partial redemption triggers a full payment of the gift amount
			# this is to keep things simple with gifts and registers


	class << self

#-------     EVENTED API METHODS

		def gift_created_event gift
			return nil unless gift.class.to_s.match /Gift/
			return nil if gift.cat != 300
			return "Gift status not approved" if !gift_status_approved?(gift)
			return "Payment time not in sync" if !gift.merchant.creation?

			puts merchant(gift)
    		puts affiliate_location(gift)
		end

		def gift_redeemed_event gift
			return nil unless gift.class.to_s.match /Gift/
			return "Gift status not approved" if !gift_status_approved?(gift)
			if gift.status != 'redeemed'
				return gift_partial_redemption_event(gift)
			end

    		puts merchant(gift)
    		puts affiliate_location(gift)
    		# puts affiliate_user(gift)
    		# puts affiliate_link(gift, gift.origin)
		end

		def gift_partial_redemption_event gift
			return "Payment time not in sync" if gift.cat >= 200 && gift.cat < 300
			redemptions = gift.redemptions
			registers = gift.registers
				# this will never == ?????
			tot_redemptions = redemptions.map(&:amount).sum
			tot_registers = registers.map(&:amount).sum
			discrepency = tot_redemptions - tot_registers
			msg = "500 Internal - Accountant - partial_redemption- #{gift.id} - Discrepency = #{discrepency}"
			puts msg.inspect
			# OpsTwilio.text_devs(msg: msg)
			return "Partial Redemption Necessary"
		end

#-------      BEHAVIOR METHODS

		def merchant gift

			# if gift is not a purchase (300), do not pay on anything other than status = redeemed
			return "Not redemption not a purchase" if gift.status != 'redeemed' && gift.cat != 300

			register = Register.init_debt(gift, gift.merchant, gift.location_fee, "loc")
			return "Register exists" if register.nil?

			if register.save
				return "Register #{register.id}"
			else
				return register.errors.messages
			end
		end

		def affiliate_location gift

			merchant = gift.merchant
			affiliate = Affiliate.where(id: merchant.affiliate_id).first
			# nil or not found
			return "No Location Affiliation" if affiliate.nil?

			register = Register.init_debt(gift, affiliate, gift.override_fee, "aff_loc")
			return "Register exists" if register.nil?

			if register.save
				return "Register #{register.id}"
			else
				return register.errors.messages
			end
		end

		# def affiliate_user gift

		# 	user_affiliation = Affiliation.get_user_affiliation_for_gift(gift)
		# 	return user_affiliation if user_affiliation.class != Affiliation

		# 	return true if gift_paid_already?(gift.id, "aff_user")

		# 	register    = create_debt(gift, user_affiliation.affiliate, "aff_user")
		# 	register.affiliation = user_affiliation
		# 	register.save
		# end

		# def affiliate_link gift, link=nil
		# 	puts "\n Affiliate affiliate_link #{gift.id} #{link}\n"
		# 	return "No link" if link.nil?
		# 	# return nil if gift.class != GiftSale
	 #        lp = LandingPage.where(link: link).first
	 #        if lp.nil?
	 #        	lp = LandingPage.click(link: link)
	 #        end
  #           lp.gifts += 1
  #           lp.users += 1
  #           gift.landing_pages << lp
  #           # binding.pry
  #           if lp.affiliate.present?
	 #            register  = create_debt(gift, lp.affiliate, "aff_link")
		# 		register.save
	 #            gift.affiliates << lp.affiliate
	 #            lp.save
	 #        end
		# end

#-------      UTILITY METHODS

	private

		def gift_status_approved? gift
			# gift is created but error on payment
			return false if ['payment_error', 'refund_cancel'].include?(gift.pay_stat)

			# gift is cancelled
			return false if ['cancel', 'expired'].include?(gift.status)

			return true
		end

		# def debt_amount gift, origin
		# 	if origin == "loc"
		# 		gift.location_fee.to_i
		# 	else
		# 		(gift.value_cents * 0.15 * 0.1).to_i
		# 	end
		# end

		# def create_debt(gift, obj, origin)
		# 	reg = Register.new
		# 	# binding.pry
		# 	reg.partner_type = obj.class.to_s
		# 	reg.partner_id   = obj.id
		# 	reg.type_of      = "debt"
		# 	reg.origin       = origin
		# 	reg.gift_id      = gift.id
		# 	reg.amount       = debt_amount(gift, origin)
		# 	reg.gift         = gift
		# 	reg
		# end
	end
end