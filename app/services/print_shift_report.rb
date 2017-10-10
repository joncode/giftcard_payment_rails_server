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
#{pre_header_xml}
#{header_xml('#shift Report')}
#{line_xml}
#{merchant_header_xml}
#{line_xml}
#{current_time_xml}
<feed line='1'/>
#{@columns}
#{line_xml}
<feed line='1'/>
<text width='1' height='2'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>&#9;</text>
<text>Total</text>
<text>&#9;&#9;&#9;</text>
<text>#{@total}</text>
<feed line='1'/>
#{support_footer_xml}
#{cut_and_post_xml}
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