def run_zap
	g = G.l
	ozh = OZ.make_request_hsh(g, QRURL, g.balance, 62734)
	puts ozh.inspect
	oz = OZ.new ozh
	r = oz.redeem_gift
	oz
end