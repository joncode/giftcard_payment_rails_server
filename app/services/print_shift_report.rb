class PrintShiftReport
	include MoneyHelper


	attr_reader :job, :merchant, :redemptions, :range, :ary, :total, :quantity, :columns

	def initialize merchant, job=nil
		@job = job
		@merchant = merchant
		@range = [@merchant.shift_start .. @merchant.now]
		@redemptions = Redemption.done_for_merchant_in_range(@merchant, @range)
		@columns = ""
	end

	def perform
		@total = 0
		@quantity = @redemptions.length
		@ary = @redemptions.map do |r|
			@total += r.amount
			[display_money(cents: r.amount, ccy: r.ccy) , r.paper_id ,  r.redemption_time]
		end
		cols = @ary.map do |data_ary|
"<feed line='2'/>
<text align='left'/>
<text font='font_a'/>
<text width='1' height='1'/>
<text reverse='false' ul='false' em='false' color='color_1'/>
<text>#{data_ary[1]}</text>
<text>&#9;&#9;</text>
<text>#{data_ary[0]}</text>"
		end
		@columns = cols.join('')
		@total = display_money(cents: @total, ccy: @merchant.try(:ccy))
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
<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">
<text lang="en"/>
<text smooth="true"/>
<text align="center"/>
<text font="font_b"/>
<text width="3" height="3"/>
<text reverse="false" ul="false" em="true" color="color_1"/>
<text>ItsOnMe Shift Report</text>
<feed unit="12"/>
<feed line="2"/>
<text font="font_a"/>
<text width="2" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{@merchant.name}</text>
<feed line="2"/>
<text font="font_c"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{@merchant.address}</text>
<feed line="2"/>
<text font="font_b"/>
<text width="1" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{@merchant.current_time}</text>
#{columns}
<feed line="2"/>
<text width="1" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>Total</text>
<text>&#9;&#9;</text>
<text>#{total}</text>
<text reverse="false" ul="false" em="false"/>
<text width="1" height="1"/>
<feed unit="12"/>
<feed line="2"/>
<text align="center"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>Text Support for any reason #{TWILIO_QUICK_NUM}</text>
<feed line="3"/>
<cut type="feed"/>
</epos-print>
</PrintData>
</ePOSPrint>
}
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