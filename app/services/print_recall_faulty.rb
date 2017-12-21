class PrintRecallFaulty
    include PrintXmlWrap
    include PrintXmlRecallHeader
    include PrintXmlRecallFooter

    attr_reader :job

    def initialize
        @job = 8612
    end

    def to_epson_xml
        xml_wrap(epson_xml)
    end

    def epson_xml
        xml_recall_header +
        xml_recall_content_faulty +
        xml_recall_footer
    end


private

    def xml_recall_content_faulty
        '<text align="left"/>' +
        '<text font="font_a"/>' +
        '<text width="1" height="1"/>' +
        '<text reverse="false" ul="false" em="false" color="color_1"/>' +
        '<text>Your printer has been recalled. This is likely due to damage or defects we\'ve detected.</text>'
    end

end
