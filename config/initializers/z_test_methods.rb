def runzap
	g = G.where.not(receiver_id: nil).l
	ozh = OZ.make_request_hsh(g, QRURL, g.balance, 62734)
	puts ozh.inspect
	oz = OZ.new ozh
	r = oz.redeem_gift
	oz
end