class PrintRecallMisconfiguration
    include PrintXmlWrap
    include PrintXmlRecallHeader
    include PrintXmlRecallFooter
    include PrintUtility
    include PrintXmlHeader
    include PrintXmlTitle
    include PrintXmlFooter

    attr_reader :job


    def initialize
        @job = 'pr_332af7c0'
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
<text>HELP TEXT&#10;GOES HERE</text>' +
        xml_footer
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
