module EmailHelper

	def items_text gift
		"<table style='padding-top:0;'>
			<tr>
				<td width='320px' style='text-align:center'>
					<h1>Gift at #{gift.provider_name}</h1>
				</td>
			</tr>
			<tr style='height: 100px;'>
				<td width='320px' style='text-align: center; font-size: 20px; padding-right:30px;'>
					#{GiftItem.items_for_email(gift)}
				</td>
			</tr>
		</table>".html_safe
	end

	# def ticket_with_text title, item_quantity_hash, value, link
	# 	"<table>
	# 		<tr>
	# 			<td width='400' height='235' background='http://gallery.mailchimp.com/d7952b3f9c7215024f55709cf/images/cecd5f31-75f9-4d56-9149-86c91f6e52ca.png' style='text-align: center'>
	# 				<table style='padding-top:0;'>
	# 					<tr><h1>#{title}</h1></tr>
	# 					<tr style='height: 100px;'>
	# 						<td width='40px'></td>
	# 						<td width='320px' style='text-align: center; font-size: 20px;'>
	# 							#{items_list(item_quantity_hash)}
	# 						</td>
	# 						<td width='40px' style='vertical-align: text-top; padding-top: 20px;'>
	# 							<b >$#{value}</b>
	# 						</td>
	# 					</tr>
	# 					<tr>
	# 						<td></td>
	# 						<td style='text-align: center;'>
	# 							<a href=#{link} style='text-decoration:underline; color:gray;'>See Gift</a>
	# 						</td>
	# 						<td></td>
	# 					</tr>
	# 				</table>
	# 			</td>
	# 		</tr>
	# 	</table>".html_safe
	# end

end
