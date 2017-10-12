class PrintRedemption
	include ActionView::Helpers::TextHelper
	include MoneyHelper
	include PrintUtility

	attr_reader :job, :merchant, :redemption, :new_street_addresses, :tab

	def initialize redemption=nil, job="xx_1234abcd", merchant=nil
		if redemption.nil?
			# redemption.gift = Gift.where(cat: 300, receiver_name: "David Leibner", giver_name: 'David Leibner').first
			redemption.gift = Gift.where(brand_card: true, status: 'redeemed').first
			redemption = Redemption.new(merchant: gift.erchant)
			redemption.hex_id = job
			redemption.token = redemption.gift.token
		end
		@job = job
		@redemption = redemption
		@merchant = redemption.merchant
		max_for_tab = 18
		@tab = "&#9;&#9;"
		@tab = "&#9;" if redemption.giver_name.length > max_for_tab || redemption.receiver_name.length > max_for_tab
		@name_width = 1
		responsive_merchant_name
	end

	def to_epson_xml
%{
#{pre_header_xml}
#{header_xml(redemption.brand_card ? '#Promo Gift Card' : '#Gift Card')}
#{merchant_header_xml}
#{line_xml}
#{current_time_xml}
<feed line='2'/>
<text align='left'/>
<text font='font_a'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Gift Giver</text>
<text>#{tab}</text>
<text>1234567890-123456789</text>
<feed line='1'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Gift Receiver</text>
<text>#{tab}</text>
<text>#{redemption.receiver_name}</text>
<feed line='1'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>4-digit Code</text>
<text>#{tab}</text>
<text>#{redemption.token}</text>
<feed line='2'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Voucher ID</text>
<text>#{tab}</text>
<text>#{redemption.paper_id}</text>
#{line_xml}
#{redemption.brand_card ? brand_value_xml : value_xml}
#{instructions_xml}
#{line_xml}
#{support_footer_xml}
#{cut_and_post_xml}
}
	end


end




__END__
