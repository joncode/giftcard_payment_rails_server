class PrintTestRedemption

	attr_reader :job, :merchant

	def initialize merchant, job="xx_1234abcd"
		@job = job
		@merchant = merchant
	end

	def to_epson_xml redemption=nil
		# make a fake redemption at location
		redemption ||= Redemption.new(merchant: merchant)
		redemption.gift = Gift.where(brand_card: true, status: 'redeemed').first
		# add a fake hex_id  xx_7234_h23i
		redemption.hex_id = job
		# get xml from calling :to_epson_xml on the fake redemption
		# insert test xml in between the actual xml
		redemption.token = redemption.gift.token
		xml = redemption.to_epson_xml
		make_test(xml)
	end

	def make_test(xml)
		return xml unless Rails.env.production?
		xml.gsub('<feed line="1', '<feed line="3"/>
<text align="center"/><text reverse="false" ul="true" em="true"/>
<text width="2" height="2"/><text>TEST VOID TEST VOID</text><feed line="1')
	end

end