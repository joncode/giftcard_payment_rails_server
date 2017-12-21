module PrintXmlRecallFooter

    def xml_recall_footer
        '<feed line="1" />' +
        '<text align="center" />' +
        '<text width="1" height="1" />' +
        '<text reverse="false" ul="false" em="false" color="color_1" />' +
        '<text>Please contact support at </text>' +
        '<text em="true" />' +
        '<text>' + TWILIO_QUICK_NUM + '</text>' +
        '<feed line="1" />' +
        '<text em="false" />' +
        '<text>This message will repeat in 24hrs.</text>'
    end

end
