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

	def button_to_html url, text
		"<div>                                
			<div style='display:block; width: 200px; margin: auto;''>
				<a href='#{url}' style='color:white; text-decoration:none;background-color:#42C2E8; display: block; padding: 10px 0; text-align:center; border-bottom:2px solid #2B99BB; border-radius: 3px;''>
				#{text}
				</a>
			</div>
		</div>".html_safe
	end

	def text_for_gift_proto gift
		image_url      = gift.provider.image
		button_url    = "#{PUBLIC_URL}/signup/acceptgift/#{NUMBER_ID + gift.id}"
		button_text   = "Claim My Gift"
		giver_name    = "Craig McAulay" 
		provider_name = gift.provider_name
		expires_at    = gift.expires_at
		details       = gift.detail
		"<div style='padding: 50px 100px;'>
			<div>
				<img src='#{image_url}' style='width: 400px;'>
			</div>
			#{items_text(gift)}
            #{button_to_html(button_url, button_text)}
		</div>
		<div style='background-color:#E2E2E2; padding: 20px;'>
			<table>
				<tr>
					<td style='width:20%''>
					</td>
					<td style='width:80%; color:#3F3F3F;'>
						<div style='color:#8E8D8D'>Craig McAulay, GM at Artifice</div>
						<div>Thank you for being a loyal customer. On your next visit please enjoy your first round on us.</div><br>
						<div style='color:#8E8D8D'>Details</div>
						<div>This gift expires on #{expires_at}.</div>
						<div>#{details}</div>
					</td>
				</tr>
			</table>
		</div>".html_safe
	end
end
