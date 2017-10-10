module EpsonXmlHelper
    extend ActiveSupport::Concern

    def to_epson_xml
    	return PrintRedemption.new(self).to_epson_xml # unless Rails.env.production?
    	# to_epson_xml_old
    end

	def to_epson_xml_old
		max_for_tab = 18
		tab = "&#9;&#9;"
		tab = "&#9;" if self.giver_name.length > max_for_tab || self.receiver_name.length > max_for_tab
		name_width = 2
		name_width = 1 if self.merchant_name.length > 21
%{
<ePOSPrint>
<Parameter>
<devid>local_printer</devid>
<timeout>20000</timeout>
<printjobid>#{self.paper_id}</printjobid>
</Parameter>
<PrintData>
<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">
<text lang="en"/>
<text smooth="true"/>
<text align="center"/>
<text font="font_b"/>
<text width="3" height="3"/>
<text reverse="false" ul="false" em="true" color="color_1"/>
<text>ItsOnMe Gift Card</text>
<feed unit="12"/>
<feed line="2"/>
<text font="font_a"/>
<text width="#{name_width}" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{self.merchant_name}</text>
<feed line="2"/>
<text font="font_c"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{self.merchant.street_address}</text>
<feed line="2"/>
<text font="font_c"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{self.merchant.city_state_zip}</text>
<feed line="2"/>
<text font="font_b"/>
<text width="1" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>#{current_time}</text>
<feed line="2"/>
<text width="1" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>4-digit Code</text>
<text>#{tab}</text>
<text>#{self.token}</text>
<feed line="2"/>
<text align="left"/>
<text font="font_a"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>Gift Giver</text>
<text>#{tab}</text>
<text>#{self.giver_name}</text>
<feed line="1"/>
<text width="1" height="1"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>Gift Receiver</text>
<text>#{tab}</text>
<text>#{self.receiver_name}</text>
<feed line="2"/>
<text width="1" height="2"/>
<text reverse="false" ul="false" em="false" color="color_1"/>
<text>Voucher ID</text>
<text>#{tab}</text>
<text>#{self.paper_id}</text>
<feed line="3"/>
<text align="center"/>
<text reverse="false" ul="false" em="true"/>
<text width="2" height="1"/>
<text>Good For</text>
<feed line="2"/>
<text align="center"/>
<text reverse="false" ul="false" em="true"/>
<text width="3" height="3"/>
<text>#{display_money(cents: self.amount, ccy: self.ccy)}</text>
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


<?xml version="1.0" encoding="utf-8"?>
<PrintRequestInfo Version="2.00">
	<ePOSPrint>
		<Parameter>
			<devid>local_printer</devid>
			<timeout>10000</timeout>
			<printjobid>#{self.paper_id}</printjobid>
		</Parameter>
		<PrintData>
			<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">
				<text lang="en"/>
				<text smooth="true"/>
				<text align="center"/>
				<text font="font_b"/>
				<text width="2" height="2"/>
				<text reverse="false" ul="false" em="true" color="color_1"/>
				<text>DELIVERY TICKET&#10;</text>
				<feed unit="12"/>
				<text>&#10;</text>
				<text align="left"/>
				<text font="font_a"/>
				<text width="1" height="1"/>
				<text reverse="false" ul="false" em="false" color="color_1"/>
				<text>Order&#9;#{self.paper_id}&#10;</text>
				<text width="1" height="1"/>
				<text reverse="false" ul="false" em="false" color="color_1"/>
				<text>#{TimeGem.datetime_to_string(DateTime.now)}</text>
				<text>Seat&#9;A-3&#10;</text>
				<text>&#10;</text>
				<text width="1" height="1"/>
				<text reverse="false" ul="false" em="false" color="color_1"/>
				<text>Alt Beer&#10;</text>
				<text>&#9;$6.00  x  2</text>
				<text x="384"/>
				<text>    $12.00&#10;</text>
				<text>&#10;</text>
				<text reverse="false" ul="false" em="true"/>
				<text width="2" height="1"/>
				<text>TOTAL</text>
				<text x="264"/>
				<text>   #{display_money(cents: self.amount, ccy: self.ccy)}&#10;</text>
				<text reverse="false" ul="false" em="false"/>
				<text width="1" height="1"/>
				<feed unit="12"/>
				<text align="center"/>
				<barcode type="code39" hri="none" font="font_a" width="2" height="60">0001</barcode>
				<feed line="3"/>
				<cut type="feed"/>
			</epos-print>
		</PrintData>
	</ePOSPrint>
	<ePOSPrint>
		<Parameter>
			<devid>kitchen_printer</devid>
			<timeout>10000</timeout>
			<printjobid>#{self.paper_id}</printjobid>
		</Parameter>
		<PrintData>
			<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">
				<text lang="en"/>
				<text smooth="true"/>
				<text rotate="true"/>
				<text align="center"/>
				<barcode type="code39" hri="none" font="font_a" width="2" height="60">0001</barcode>
				<feed unit="30"/>
				<text align="left"/>
				<text>0001</text>
				<text>    03-19-2013 13:53:15&#10;</text>
				<text reverse="true"/>
				<text> Kitchen </text>
				<text reverse="false"/>
				<text>    </text>
				<text>[New Order] </text>
				<text>&#10;</text>
				<text width="1" height="2"/>
				<text>Seat: </text>
				<text width="2" height="2"/>
				<text>A-3</text>
				<text width="1" height="1"/>
				<text>&#10;</text>
				<text width="2" height="2"/>
				<text>2</text>
				<text width="1" height="2"/>
				<text>&#9;Alt Beer</text>
				<text width="1" height="1"/>
				<text>&#10;</text>
				<cut type="feed"/>
				<text rotate="false"/>
			</epos-print>
		</PrintData>
	</ePOSPrint>
</PrintRequestInfo>