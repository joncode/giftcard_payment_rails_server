class UserAfterCreateEvent

	@queue = :after_save

	def self.perform(user_or_user_id)
		puts "\n user #{user_or_user_id} is in UserAfterCreateEvent.rb\n"

		user = user_or_user_id.kind_of?(User) ? user_or_user_id : User.find(user_or_user_id)

		if user.client_id == 2
			puts "PTEG user created"
			self.gift_user_for_pt user
		end

	end

	def self.gift_user_for_pt user
		s = Social.where(network_id: user.email, network: 'email')
		if s.count > 0
			puts "PTEG user on list"
			merchant = Merchant.find 410
			client = Client.find 2

			menu_item = MenuItem.find 4326
			hsh = menu_item.serialize_to_app(1)
			sc = [hsh].to_json
			# user = User.find 8248

			gift = Gift.new(
				merchant_id: merchant.id,
				giver_name: "PT's Entertainment Group",
				detail: "Valid until December 1st, Only valid at locations with Newcastle on draft.",
				message: "Enjoy this Newcastle Draft on us!",
				receiver_name: user.email,
				provider_name: merchant.name,
				giver_id: merchant.id,
				receiver_email: user.email,
				cat: 200,
				giver_type: "BizUser",
				value: "6",
				cost: "0",
				balance: 600,
				expires_at: DateTime.new(2015, 12,1),
				client_id: 2,
				partner_id: client.partner_id,
				partner_type: client.partner_type,
				origin: "New User Created")
			gift.shoppingCart = sc
			if gift.save
				puts "PTEG user gifted"
			else
				puts "500 Internal #{gift.errors}"
			end
		end
	end


end