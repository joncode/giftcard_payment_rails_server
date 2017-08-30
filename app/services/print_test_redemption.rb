class PrintTestRedemption

	attr_reader :job, :merchant

	def initialize job, merchant
		@job = job
		@merchant = merchant
	end

	def to_epson_xml
		# make a fake redemption at location
		# add a fake hex_id  xx_7234_h23i
		# get xml from calling :to_epson_xml on the fake redemption
		# insert test xml in between the actual xml
%{
<ePOSPrint>
<Parameter>
	<devid>local_printer</devid>
	<timeout>20000</timeout>
	<printjobid>#{job}</printjobid>
</Parameter>
<PrintData>
	<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">
		<text lang="en"/>
		<text smooth="true"/>
		<text align="center"/>
		<text font="font_b"/>
		<text width="2" height="2"/>
		<text reverse="false" ul="false" em="true" color="color_1"/>
		<text>ItsOnMe Gift Card&#10;</text>
		<feed unit="12"/>
		<text>&#10;</text>
		<text align="left"/>
		<text font="font_a"/>
		<text width="1" height="1"/>
		<text reverse="false" ul="false" em="false" color="color_1"/>
		<text>FAKE REDEMPTION&#10;</text>
		<text width="1" height="1"/>
		<text reverse="false" ul="false" em="false" color="color_1"/>
		<text>#{merchant.current_time}</text>
		<text>&#10;</text>
		<text width="1" height="1"/>
		<text reverse="false" ul="false" em="false" color="color_1"/>
		<text>Text Support for any reason #{TWILIO_QUICK_NUM}</text>
		<feed line="3"/>
		<cut type="feed"/>
	</epos-print>
</PrintData>
</ePOSPrint>
}
	end

end