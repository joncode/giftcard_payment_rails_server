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

end# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#  origin         :string(255)
#

