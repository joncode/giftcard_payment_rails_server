class GiftAffiliate < GiftCampaign

	# args = params.require(:data).permit(:rec_net, :rec_net_id, :c_item_id, :link)

	def self.create args

		resp = self.check_for_previous_campaign_gift args
		if resp.nil?
			new_args = self.convert_args_for_gift_campaign(args)
			super new_args
		else
			return resp
		end
	end

private

	def self.check_for_previous_campaign_gift args
		u_gifts = 0
		n_gifts = 0
		campaign = CampaignItem.find(args["c_item_id"]).campaign

		if user = self.find_user(args)
			u_gifts = Gift.where(giver_id: campaign.id, giver_type: "Campaign", receiver_id: user.id).count
		end
		n_gifts = if args["rec_net"] == 'em'
			Gift.where(giver_id: campaign.id, giver_type: "Campaign", receiver_email: args["rec_net_id"]).count
		elsif args["rec_net"] == 'ph'
			Gift.where(giver_id: campaign.id, giver_type: "Campaign", receiver_phone: args["rec_net_id"]).count
		end
		unless  (u_gifts + n_gifts) == 0
			return "Sorry, #{args["rec_net_id"]} has already received a gift.  Each person is limited to one gift per campaign."
		end
		nil
	end

	def self.find_user args
		PeopleFinder.search_db(args["rec_net"], args["rec_net_id"])
	end

	def self.convert_args_for_gift_campaign args
		new_args = { "payable_id" => args["c_item_id"]}
		case args["rec_net"]
		when "em"
			new_args["receiver_email"] = args["rec_net_id"]
		when "ph"
			new_args["receiver_phone"] = args["rec_net_id"]
		end
		new_args
	end

end