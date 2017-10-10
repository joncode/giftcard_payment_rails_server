class PrintRedemption
	include ActionView::Helpers::TextHelper
	include MoneyHelper
	include PrintUtility

	attr_reader :job, :merchant, :redemption, :new_street_addresses, :tab

	def initialize redemption=nil, job="xx_1234abcd"
		if redemption.nil?
			redemption = Redemption.new(merchant: merchant)
			# add a fake hex_id  xx_7234_h23i
			redemption.hex_id = job
			redemption.gift = Gift.where(cat: 300, receiver_name: "David Leibner", giver_name: 'David Leibner').first
			# get xml from calling :to_epson_xml on the fake redemption
			# insert test xml in between the actual xml
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
#{header_xml('#Gift Card')}
#{line_xml}
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
<text>#{redemption.giver_name}</text>
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
#{value_xml}
#{support_footer_xml}
#{cut_and_post_xml}
}
	end


end




__END__
