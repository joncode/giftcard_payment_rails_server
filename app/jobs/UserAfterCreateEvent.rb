class UserAfterCreateEvent

	@queue = :after_save

	def self.perform(user_or_user_id)
		puts "\n user #{user_or_user_id} is in UserAfterCreateEvent.rb\n"

		user = user_or_user_id.kind_of?(User) ? user_or_user_id : User.find(user_or_user_id)

		if user && user.partner_id == 29 && user.partner_type == "Affiliate"
			puts "PTEG user created"
			self.gift_user_for_pt user
		end

	end

	def self.gift_user_for_pt user
		# s = Social.where(network_id: user.email, network: 'email').where('created_at > ?', DateTime.new(2016, 4, 20))
		if user.email.present?

			puts "PTEG user on list"
			merchant = Merchant.find 410

			## THINGS THAT MATTER PER GIFT
			## IT SHOULD CALCULATE THE VALUE / COST / BALANCE AUTOMATICALLY

			giver_name_for_gift = "PT's Entertainment Group"

			menu_item = MenuItem.find 5448
			hsh = menu_item.serialize_to_app(1)
			sc = [hsh].to_json

			detail = "This gift is good until June 30th, please enjoy before then."
			msg = "Thank you for downloading the PT's Entertainment Group mobile app and signing up for eGifting powered by ItsOnMe. Enjoy our gift to you of $5 off your bill."
			expires_at = DateTime.new(2016, 7, 1)

			gift = Gift.new(
				merchant_id: merchant.id,
				provider_name: merchant.name,
				giver_id: merchant.id,
				giver_name: giver_name_for_gift,
				giver_type: "BizUser",
				detail: detail,
				message: msg,
				receiver_name: user.email,
				receiver_email: user.email,
				cat: 200,
				value: "5",
				cost: "0",
				balance: 500,
				expires_at: expires_at,
				client_id: user.client_id,
				partner_id: user.partner_id,
				partner_type: user.partner_type,
				origin: "New User Created")

			gift.shoppingCart = sc

			gift.send_internal_email
			if gift.save
				puts "PTEG user gifted"
				gift.messenger
			else
				puts "500 Internal #{gift.errors}"
			end
		end
	end


end