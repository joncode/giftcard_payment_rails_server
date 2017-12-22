module PrintXmlWrap

    def complete_xml_wrap(xml_job)
        xml = '<?xml version="1.0" encoding="utf-8"?><PrintRequestInfo Version="2.00">'
        xml += xml_wrap(xml_job)
        xml += '</PrintRequestInfo>'
        xml
    end

	def xml_wrap(xml_job)
%{
<ePOSPrint>
<Parameter>
<devid>local_printer</devid>
<timeout>20000</timeout>
<printjobid>#{@job}</printjobid>
</Parameter>
<PrintData>
<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">
<text lang="en"/>
#{xml_job}
<feed line="3"/>
<cut type="feed"/>
</epos-print>
</PrintData>
</ePOSPrint>
}
	end

end