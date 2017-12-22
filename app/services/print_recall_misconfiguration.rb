class PrintRecallMisconfiguration
    include PrintXmlWrap
    include PrintXmlRecallHeader
    include PrintXmlRecallFooter
    include PrintUtility

    attr_reader :job

    def initialize
        @job = 8600
    end


    def to_epson_xml
        return "
<ePOSPrint>
<Parameter>
<devid>local_printer</devid>
<timeout>20000</timeout>
<printjobid>rd_332af7c0</printjobid>
</Parameter>
<PrintData>
<epos-print xmlns='http://www.epson-pos.com/schemas/2011/03/epos-print'>
<text lang='en'/>
<text smooth='true'/>
<text align='center'/>
<text font='font_b'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>ItsOnMe</text>
<feed line='3'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>#Promo Gift Card</text><feed line='1'/>
<feed line='1'/>
<text font='font_a'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Bourbon and Brañch</text>
<feed line='1'/>
<feed line='1'/>
<text font='font_c'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>501 Jones St</text>
<feed line='1'/>
<text font='font_c'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>San Francisco, CA 94102</text>
<feed />
<text align='center'/>
<text font='font_a'/>
<text width='2' height='1'/>
<text reverse='false' ul='true' em='true' color='color_1'/>
<text>                   </text><feed />
<feed line='1'/>
<text font='font_b'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>December 21, 2017  4:38 PM</text>
<feed line='2'/>
<text align='left'/>
<text font='font_a'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Gift Giver</text>
<text>&#9;&#9;</text>
<text>Bourbon and Brañch</text>
<feed line='1'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Gift Receiver</text>
<text>&#9;&#9;</text>
<text>Itsonme Gifting</text>
<feed line='1'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Voucher ID</text>
<text>&#9;&#9;</text>
<text>RD-332A-F7C0</text>
<feed line='2'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>4-digit Code</text>
<text>&#9;&#9;</text>
<text>1804</text>
<feed />
<text align='center'/>
<text font='font_a'/>
<text width='2' height='1'/>
<text reverse='false' ul='true' em='true' color='color_1'/>
<text>                   </text><feed />
<feed line='1'/>
<text align='center'/>
<text reverse='false' ul='false' em='true'/>
<text width='2' height='1'/>
<text>Good For</text>
<feed line='2'/>
<text align='center'/>
<text reverse='false' ul='false' em='true'/>
<text width='3' height='3'/>
<text>$50</text>
<feed line='1'/>
<feed line='1'/>
<text font='font_c'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Enjoy this gift. Text support if you have
any questions.</text>
<feed />
<text align='center'/>
<text font='font_a'/>
<text width='2' height='1'/>
<text reverse='false' ul='true' em='true' color='color_1'/>
<text>                   </text><feed />
<text reverse='false' ul='false' em='false'/>
<text width='1' height='1'/>
<feed unit='12'/>
<feed line='1'/>
<text align='center'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Text Support for any reason 310-736-4884</text>
<feed line='5'/>
<cut type='feed'/>
</epos-print>
</PrintData>
</ePOSPrint>"
        # xml_wrap(epson_xml)
    end

    def epson_xml
        xml_recall_header +
        xml_recall_content_misconfiguration +
        line_xml +
        xml_recall_footer
    end


private

    def xml_recall_content_misconfiguration
        '<text align="center"/>' +
        '<text font="font_a"/>' +
        '<text width="1" height="1"/>' +
        '<text reverse="false" ul="false" em="false" color="color_1"/>' +
        '<text>This printer\'s configuration is incorrect</text>' +
        '<feed line="1" />'  +
        '<text>and requires support.</text>'
    end

end
