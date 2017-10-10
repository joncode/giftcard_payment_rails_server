module PrintUtility

	def responsive_merchant_name
		@name_width = 1 if merchant.name.length > 21
		merchant.name[0..42]
	end

	def responsive_city_state_zip
		merchant.city_state_zip[0..42]
	end

	def responsive_street_address
		width = 42

		sa = merchant.street_address.gsub("\n",'')
		address_ary = word_wrap(sa, line_width: width).strip.split("\n")
		@new_street_addresses = address_ary.map do |addy|
			single_line(addy)
		end
	end

	def single_line str
"<feed line='1'/>
<text font='font_c'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>#{str}</text>"
	end

	def header_xml text=''
"<text align='center'/>
<text font='font_b'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>#{SERVICE_NAME}</text>
<feed line='3'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>#{text}</text><feed line='2'/>"
	end

	def merchant_header_xml
"<feed line='1'/>
<text font='font_a'/>
<text width='#{@name_width}' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>#{responsive_merchant_name}</text>
<feed line='1'/>
#{responsive_street_address.join('')}
<feed line='1'/>
<text font='font_c'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>#{responsive_city_state_zip}</text>"
	end


	def current_time_xml
"<feed line='2'/>
<text font='font_b'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>#{merchant.current_time}</text>"
	end


	def line_xml
"<feed />
<text align='center'/>
<text font='font_a'/>
<text width='2' height='1'/>
<text reverse='false' ul='true' em='true' color='color_1'/>
<text>                   </text>"
	end

	def support_footer_xml
"<text reverse='false' ul='false' em='false'/>
<text width='1' height='1'/>
<feed unit='12'/>
<feed line='2'/>
<text align='center'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Text Support for any reason #{TWILIO_QUICK_NUM}</text>
<feed line='5'/>"
	end


end