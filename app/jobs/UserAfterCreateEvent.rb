class UserAfterCreateEvent

	@queue = :after_save

	def self.perform(user_or_user_id)
		puts "\n user #{user_or_user_id} is in UserAfterCreateEvent.rb\n"

		user = user_or_user_id.kind_of?(User) ? user_or_user_id : User.find(user_or_user_id)

		if user && user.partner_id == 29 && user.partner_type == "Affiliate"
			puts "PTEG user created"
			# self.gift_user_for_pt user
		end

	end

	def self.gift_user_for_pt user, client=nil
		# s = Social.where(network_id: user.email, network: 'email').where('created_at > ?', DateTime.new(2016, 4, 20))
		if user.email.present?

			if client.kind_of?(Client)
				client_id = client.id
				partner_id = client.partner_id
				partner_type = client.partner_type
			else
				client_id = user.client_id
				partner_id = user.partner_id
				partner_type = user.partner_type
			end

			puts "PTEG user on list"
			merchant = Merchant.find 410

			## THINGS THAT MATTER PER GIFT
			## IT SHOULD CALCULATE THE VALUE / COST / BALANCE AUTOMATICALLY

			giver_name_for_gift = "PT's Entertainment Group"

			menu_item = MenuItem.find 5448
			hsh = menu_item.serialize_to_app(1)
			sc = [hsh].to_json

			detail = "This gift is good until June 30th, please enjoy before then."
			msg = "Thank you for downloading the PT's Entertainment Group mobile app and signing up for eGifting powered by ItsOnMe. \
			Enjoy our gift to you of $5 off your bill.  This gift is good until June 30th, please enjoy before then."
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
				client_id: client_id,
				partner_id: partner_id,
				partner_type: partner_type,
				origin: "New User Created")

			gift.shoppingCart = sc

			if gift.save
				gift.send_internal_email
				puts "PTEG user gifted"
				gift.messenger
				return { status: 1, data: "Success Gift created"}
			else
				puts "500 Internal #{gift.errors}"
				return { status: 0, data: "Unable to create gift "}
			end
		else
			return { status: 0, data: "User does not have an email"}
		end
	end


end