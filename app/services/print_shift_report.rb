class PrintShiftReport
	include MoneyHelper
    include PrintXmlHeader
    include PrintXmlTitle
    include PrintXmlFooter


	attr_reader :job, :merchant, :redemptions, :range, :ary, :total, :quantity

	def initialize merchant, job=nil
		@job = job
		@merchant = merchant
		@range = [@merchant.shift_start .. @merchant.now]
		@redemptions = Redemption.done_for_merchant_in_range(@merchant, @range)
	end

	def perform
		@total = 0
		@quantity = @redemptions.length
		@ary = @redemptions.map do |r|
			@total += r.amount
			[display_money(cents: r.amount, ccy: r.ccy) , r.paper_id ,  r.redemption_time]
		end
		@total = display_money(cents: @total, ccy: @merchant.try(:ccy))
	end

	def to_epson_xml
		xml_wrap(epson_xml)
	end

	def epson_xml
		xml_header +
		xml_title +
'<feed unit="12"/>
<text>&#10;</text>
<text align="left"/>
<text font="font_a"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>SHIFT REPORT&#10;</text>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{merchant.current_time}</text>' +
		xml_footer
	end

end




__END__


SHIFT REDEMPTION


get the printe queues OR redemptions for the day that were successfull

get the merchant
start at 8 am inb timezone of merchant
get all redemptions for now till that time

range = [m.shift_start .. m.now]
rs = Redemption.where(merchant_id: m.id, created_at: range, status: 'done')

array of todays redemptions


table of complelete redemption
value , paper id , timestamp


rs.each do |r|
	display_money(cents: r.amount, ccy: r.ccy) , r.paper_id ,  r.redemption_time
end


totals

total amount , total redemptions

total_amount = rs.inject(0) { |sum, p| sum + p.amount }
display_money(cents: total_amount, ccy: rs[0].ccy)

rs.length