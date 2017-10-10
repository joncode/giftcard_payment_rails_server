module PrintUtility

	def responsive_merchant_name
		@name_width = 1 if merchant.name.length > 21
		merchant.name[0..42]
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



	def header text=''
"<text align='center'/>
<text font='font_b'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>#{SERVICE_NAME}</text>
<feed line='3'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>#{text}</text>"
	end












end