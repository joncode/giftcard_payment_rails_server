module PrintUtility

	def max_length(str='')
		str[0..42]
	end

	def responsive_merchant_name
		@name_width = 1 if merchant.name.length > 21
		max_length(merchant.name)
	end

	def responsive_city_state_zip
		max_length(merchant.city_state_zip)
	end

	def responsive_brand_card_text
		width = 21
		word_wrap(redemption.text_brand_card, line_width: width).strip.split("\n")
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
<text>#{text}</text><feed line='1'/>"
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
"<feed line='1'/>
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
<text>                   </text><feed />"
	end

	def support_footer_xml
"<text reverse='false' ul='false' em='false'/>
<text width='1' height='1'/>
<feed unit='12'/>
<feed line='1'/>
<text align='center'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Text Support for any reason #{TWILIO_QUICK_NUM}</text>
<feed line='5'/>"
	end

	def pre_header_xml
"<ePOSPrint>
<Parameter>
<devid>local_printer</devid>
<timeout>20000</timeout>
<printjobid>#{job}</printjobid>
</Parameter>
<PrintData>
<epos-print xmlns='http://www.epson-pos.com/schemas/2011/03/epos-print'>
<text lang='en'/>
<text smooth='true'/>"
	end

	def cut_and_post_xml
"<cut type='feed'/>
</epos-print>
</PrintData>
</ePOSPrint>"
	end

	def value_xml
"<feed line='1'/>
<text align='center'/>
<text reverse='false' ul='false' em='true'/>
<text width='2' height='1'/>
<text>Good For</text>
<feed line='2'/>
<text align='center'/>
<text reverse='false' ul='false' em='true'/>
<text width='3' height='3'/>
<text>#{display_money(cents: redemption.amount, ccy: redemption.ccy)}</text>
<feed line='1'/>"
	end

	def brand_value_xml
"<feed line='1'/>
<text align='center'/>
<text reverse='false' ul='false' em='true'/>
<text width='2' height='1'/>
<text>Good For</text>
<feed line='2'/>
<text align='center'/>
<text reverse='false' ul='false' em='true'/>
<text width='2' height='2'/>
<text>#{responsive_brand_card_text}</text>
<feed line='1'/>
#{single_line('retail value: ' + display_money(cents: redemption.amount, ccy: redemption.ccy))}"
	end

	def instructions_xml
		single_line(redemption.detail)
	end



end