class PrintRecallMisconfiguration
    include PrintXmlWrap
    include PrintXmlRecallHeader
    include PrintXmlRecallFooter
    include PrintUtility

    def initialize; end


    def to_epson_xml
        xml_wrap(epson_xml)
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
