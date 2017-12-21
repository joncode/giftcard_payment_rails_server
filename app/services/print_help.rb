class PrintHelp
	include PrintXmlWrap
    include PrintXmlHeader
    include PrintXmlTitle
    include PrintXmlFooter


	attr_reader :job, :merchant

	def initialize merchant, job=nil
		@job = job
		@merchant = merchant
	end

	def to_epson_xml
		xml_wrap(epson_xml)
	end

	def epson_xml
		xml_header +
		xml_title +
'<text>&#10;</text>
<text align="left"/>
<text font="font_a"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>HELP&#10;</text>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>' + merchant.current_time + '</text>' +
		xml_footer
	end

end



__END__


1. print shift report
2. print help
3. reprint rdemption voucher



