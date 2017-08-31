class PrintHelp

	attr_reader :job, :merchant

	def initialize job, merchant
		@job = job
		@merchant = merchant
	end

	def to_epson_xml
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
<text>HELP&#10;</text>
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