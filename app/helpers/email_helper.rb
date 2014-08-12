module EmailHelper
	include TimeHelper

	def items_text gift
		"<table style='padding-top:0;'>
			<tr>
				<td width='320px' style='text-align:left'>
					<div style='font-size:25px; padding-top:10px;'>$#{gift.value} Gift at #{gift.provider_name}</div>
				</td>
			</tr>
			<tr>
				<td>
					<div style='font-size:15px; color:#8E8D8D;'>Gift Expires: #{make_date_s(gift.expires_at)}</div>
				</td>
			</tr>
			<tr style='height: 100px;'>
				<td style='text-align: left; font-size: 20px;'>
					#{GiftItem.items_for_email(gift)}
				</td>
			</tr>
		</table>".html_safe
	end

	def button_to_html url, text
		"<div>                                
			<div style='display:block; width: 200px; margin:auto;'>
				<a href='#{url}' style='color:white; text-decoration:none;background-color:#42C2E8; display: block; padding: 10px 0; text-align:center; border-bottom:2px solid #2B99BB; border-radius: 3px; font-size:20px;'>
				#{text}
				</a>
			</div>
		</div>".html_safe
	end

	def text_for_gift_proto gift
		image_url      = gift.provider.image
		button_url    = "http://www.itson.me/signup/acceptgift?id=#{NUMBER_ID + gift.id}"
		button_text   = "Claim My Gift"
		provider_name = gift.provider_name
		expires_at    = make_ordinalized_date_with_day(gift.expires_at)
		details       = gift.detail
		"<div style='padding: 0 100px 20px 100px;'>
			<div>
				<img src='#{image_url}' style='width: 400px;'>
			</div>
			#{items_text(gift)}
			<div style='padding-bottom:20px; font-size:16px;'>
				#{provider_name} has partnered with It's On Me to deliver this gift to some of its favorite customers. To claim this gift simply click the button and download the app. Use this email address at sign-up to receiver your gift.
			</div>
            #{button_to_html(button_url, button_text)}
		</div>
		<div style='background-color:#E2E2E2; padding: 10px;'>
			<table>
				<tr>
					<td style='width:15%;'></td>
					<td style='width:70%; color:#3F3F3F;'>
						<div style='color:#8E8D8D'>The staff at Artifice</div>
						<div>Thank you for being a loyal customer. On your next visit please enjoy your first round on us.</div><br>
					</td>
					<td style='width:15%;'></td>
				</tr>
				<tr>
					<td></td>
					<td>
						<div style='color:#8E8D8D'>Details</div>
						<div>This gift expires on #{expires_at}.</div>
						<div>#{details}</div>
					</td>
				</tr>
			</table>
		</div>".html_safe
	end
end
