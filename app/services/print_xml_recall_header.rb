module PrintXmlRecallHeader

    def xml_recall_header
        str  = ''
        str += '<text smooth="true" />'
        str += '<text align="center" />'
        str += '<text font="font_b" />'
        str += '<text width="2" height="3" />'
        str += '<text reverse="false" ul="false" em="true" color="color_1" />'
        str += '<text>-- ItsOnMe Recovery --</text>'
        str += '<feed line="3" />'
    end

end
