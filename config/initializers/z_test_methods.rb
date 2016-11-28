def runzap
	g = G.where.not(receiver_id: nil).l
	ozh = OZ.make_request_hsh(g, QRURL, g.balance, 62734)
	puts ozh.inspect
	oz = OZ.new ozh
	r = oz.redeem_gift
	oz
end

def tok
	{"id"=>850, "user_id"=>nil, "nickname"=>"oliver@qa111716",
		"name"=>"Oliver QA 111716", "number_digest"=>nil, "last_four"=>"1758",
		"month"=>"02", "year"=>"18", "csv"=>"456", "brand"=>"Visa",
		  "cim_token"=>nil, "zip"=>"98101", "active"=>true, "partner_id"=>17,
		  "partner_type"=>"Affiliate", "origin"=>"QA 111716", "client_id"=>1,
		  "ccy"=>"USD", "trans_token"=>nil, "country"=>nil, "stripe_user_id"=>nil,
		   "stripe_id"=>"tok_19H0dvHMscfhJNrcJGCliktf", "address"=>nil, "resp_json"=>nil
	}
end