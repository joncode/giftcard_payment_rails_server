class PrintTestRedemption

	attr_reader :job, :merchant

	def initialize job, merchant
		@job = job
		@merchant = merchant
	end

	def to_epson_xml
		# make a fake redemption at location
		redemption = Redemption.new(merchant: merchant)
		# add a fake hex_id  xx_7234_h23i
		redemption.hex_id = "xx_1234abcd"
		redemption.gift = Gift.where(cat: 300).last
		# get xml from calling :to_epson_xml on the fake redemption
		# insert test xml in between the actual xml
		redemption.to_epson_xml
	end

end