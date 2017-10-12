class PrintTestRedemption

	attr_reader :job, :merchant

	def initialize merchant, job="xx_1234abcd", redemption
		@job = job
		@merchant = merchant
		@redemption = redemption
	end

	def to_epson_xml redemption=nil
		xml = @redemption.to_epson_xml
		make_test(xml)
	end

	def make_test(xml)
		return xml unless Rails.env.production?
		xml.gsub('<feed line="1', '<feed line="3"/>
<text align="center"/><text reverse="false" ul="true" em="true"/>
<text width="2" height="2"/><text>TEST VOID TEST VOID</text><feed line="1')
	end

end