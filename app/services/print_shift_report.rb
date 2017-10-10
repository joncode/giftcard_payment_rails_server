class PrintShiftReport
	include ActionView::Helpers::TextHelper
	include MoneyHelper
	include PrintUtility


	attr_reader :job, :merchant, :redemptions, :range, :total, :quantity, :columns, :new_street_addresses

	def initialize merchant, job=nil
		@job = job
		@merchant = merchant
		@range = [@merchant.shift_start .. @merchant.now]
		if Rails.env.production?
			@redemptions = Redemption.done_for_merchant_in_range(@merchant, @range).order(response_at: :asc)
		else
			@redemptions = Redemption.last(10)
		end
		@columns = ""
		@name_width = 2
		responsive_merchant_name
		# @name_width = 1 if @merchant.name.length > 21
		perform
	end

# 	def responsive_street_address
# 		width = 42
# 		sa = merchant.street_address.gsub("\n",'')
# 		address_ary = word_wrap(sa, line_width: width).strip.split("\n")
# 		@new_street_addresses = address_ary.map do |addy|
# 			single_line(addy)
# 		end
# 	end

# 	def single_line str
# "<feed line='1'/>
# <text font='font_c'/>
# <text width='1' height='1'/>
# <text reverse='false' ul='false' em='false' color='color_1'/>
# <text>#{str}</text>"
# 	end

	def perform
		@total_cents = 0
		@quantity = @redemptions.length
		if @quantity == 0
			@total = display_money(cents: 0, ccy: @merchant.try(:ccy), zeros: true)
			@columns = single_line("No Redemptions Today")
		else
			cols = @redemptions.map do |r|
				@total_cents += r.amount
	"<feed line='1'/>
	<text align='left'/>
	<text font='font_a'/>
	<text width='1' height='1'/>
	<text reverse='false' ul='false' em='false' color='color_1'/>
	<text>#{r.paper_id}</text>
	<text>&#9;</text>
	<text>     #{r.redemption_time}</text>
	<text>&#9;</text>
	<text>  #{display_money(cents: r.amount, ccy: r.ccy, zeros: true)}</text>"
			end
			@columns = cols.join('')
			@total = display_money(cents: @total_cents, ccy: @merchant.try(:ccy), zeros: true)
		end
	end

	def to_epson_xml
%{
<ePOSPrint>
<Parameter>
<devid>local_printer</devid>
<timeout>20000</timeout>
<printjobid>#{job}</printjobid>
</Parameter>
<PrintData>
<epos-print xmlns='http://www.epson-pos.com/schemas/2011/03/epos-print'>
<text lang='en'/>
<text smooth='true'/>
<text align='center'/>
<text font='font_b'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>ItsOnMe</text>
<feed line='3'/>
<text width='3' height='3'/>
<text reverse='false' ul='false' em='true' color='color_1'/>
<text>#shift Report</text>
<feed line='3'/>
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
<text>#{@merchant.city_state_zip}</text>
<feed line='2'/>
<text font='font_b'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>#{@merchant.current_time}</text>
<feed line='1'/>
#{@columns}
<feed />
<text align='center'/>
<text font='font_a'/>
<text width='2' height='1'/>
<text reverse='false' ul='true' em='true' color='color_1'/>
<text>                   </text>
<feed line='2'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>&#9;</text>
<text>Total</text>
<text>&#9;&#9;&#9;</text>
<text>#{@total}</text>
<text reverse='false' ul='false' em='false'/>
<text width='1' height='1'/>
<feed unit='12'/>
<feed line='2'/>
<text align='center'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>Text Support for any reason #{TWILIO_QUICK_NUM}</text>
<feed line='3'/>
<cut type='feed'/>
</epos-print>
</PrintData>
</ePOSPrint>
}
	end


end




__END__


SHIFT REDEMPTION

m = G.l.merchant
p = PrintShiftReport.new(M.l).to_epson_xml





m = G.l.merchant
p =  PrintShiftReport.new m
p.perform
p.to_epson_xml

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



x = "The Linq, Suite 22, 3545 Las Vegas Boulevard South"
m = M.l
m.address = x
p =  PrintShiftReport.new m
xml = p.to_epson_xml