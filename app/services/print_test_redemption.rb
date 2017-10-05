class PrintTestRedemption

	attr_reader :job, :merchant

	def initialize merchant, job=nil
		@job = job
		@merchant = merchant
	end

	def to_epson_xml
		# make a fake redemption at location
		redemption = Redemption.new(merchant: merchant)
		# add a fake hex_id  xx_7234_h23i
		redemption.hex_id = "xx_1234abcd"
		redemption.gift = Gift.where(cat: 300, receiver_name: "David Leibner", giver_name: 'David Leibner').first
		# get xml from calling :to_epson_xml on the fake redemption
		# insert test xml in between the actual xml
		redemption.token = redemption.gift.token
		xml = redemption.to_epson_xml

		make_test(xml)
	end

	def make_test(xml)
		xml.gsub('<feed line="1', '<feed line="2"/>
<text align="center"/>
<text reverse="false" ul="false" em="true"/>
<text width="2" height="1"/>
<text>TEST VOID TEST VOID</text><feed line="1')
	end

end