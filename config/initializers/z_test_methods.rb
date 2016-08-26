def run_zap
	g = G.l
	ozh = OZ.make_request_hsh(g, QRURL, g.balance)
	puts ozh.inspect
	oz = OZ.new ozh
	r = oz.redeem_gift
	oz
end