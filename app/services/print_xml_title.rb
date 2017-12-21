module PrintXmlTitle

	def xml_title
'<feed line="2"/>
<text font="font_a"/>
<text width="2" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>' + @merchant.name + '</text>
<feed line="2"/>
<text font="font_c"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>' + @merchant.address + '</text>
<feed line="2"/>
<text font="font_b"/>
<text width="1" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>' + @merchant.current_time + '</text>
<feed line="2"/>'
	end


end