module EmailHelper
	include TimeHelper
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::AssetTagHelper

	def text_for_welcome_from_dave user
		string = "Hi #{ user.first_name },\n\n"
		string += "Welcome! I'm the CEO of ItsOnMe and wanted to welcome you and thank you for joining.\n"
		string += "ItsOnMe is the easiest way to say, 'Thank you, this round is on me.'\n\n"
		string += "If you have any feedback on what you like/dislike or want to change, please let us know.\n\n"
		string += "You can find us on Twitter(http://twitter.com/itsonme), Facebook(http://www.facebook.com/itsonme), or email us at feedback@itson.me\n\n"
		string += "Cheers,\n\n"
		string += "David Leibner\n"
		string
	end

	def text_for_user_confirm_email user, link
		user_first_name = user.first_name
		button_url      = link
		button_text     = "Confirm Email"
		"<div style=#{default_style}>
		#{header_text("Confirm Email")}
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px;'>
					Welcome to ItsOnMe #{user_first_name}! Please click the link to confirm your email address.
				</div>
		#{button_text(button_url, button_text)}
					</div>
		</div>".html_safe
	end

	def text_for_user_reset_password user, token, subdomain=nil

		if user.class == MtUser
			reset_url_string = "mt_users/password/edit?reset_password_token=#{token}"
			if ["partner", "qapartner"].include?(subdomain)
				button_url  = "#{PUBLIC_URL_PT}/#{reset_url_string}"
			else
				button_url  = "#{PUBLIC_URL_MT}/#{reset_url_string}"
			end
		elsif user.class == AtUser
			button_url  = "#{PUBLIC_URL_AT}/reset_password?token=#{user.reset_token}"
		else
			button_url  = "#{PUBLIC_URL}/account/resetpassword/#{user.reset_token}"
		end
		button_text     = "Reset Password"

		"<div style=#{default_style}>
		#{header_text("Reset Password")}
			<div style='padding: 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px;'>
					Forgot your password? Let's get you a new one.
				</div>
			</div>
		#{ button_text(button_url, button_text) }
			<div style='padding: 30px; font-size:14px;'>
				<div style='padding-bottom:20px;'>
					Help! I didn't request this.
				</div>
				<div style='padding-bottom:20px;'>
					If you were not trying to reset your password, just ignore this email. Your account is still secure. Most likely, someone mistyped their email address while trying to reset their own password. If you have concerns, contact us at <a href='mailto:support@itson.me' target='_blank' style='color:#3F3F3F'>support@itson.me</a>
				</div>
					</div>
		</div>".html_safe
	end

	def text_for_reminder_hasnt_gifted user
		user_first_name = user.first_name
		"<div style=#{default_style}>
			<div style='width:100%; text-align:center;'>
						<div style='color:#3F3F3F; font-size:30px; font-weight:lighter; padding-top:20px;''>
					<span><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/gold_celebrate_icon_hi074a.jpg'></span>
					<span>Celebrate</span>
						</div>
				</div>
			<hr style='border-bottom:1px solid #C9C9C9;'>
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px;'>
					<div>Hi #{user_first_name},</div><br/>
					<div>It's a good day to make someone happy. Use ItsOnMe to send a gift and say you're awesome, congrats, or thank you.</div>
				</div>
			</div>
			<div style='padding-bottom:50px;'>
				<table style='width: 100%;'>
					<tr>
						<td style='text-align:center; width:33%;'>
							<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/gold_heart_zzd8mq.jpg'></div><br/>
								<div>Find something new to love</div>
		</td>
						<td style='text-align:center; width:33%;'>
							<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1410563975/gold_gift_su2ced.jpg'></div><br/>
								<div>Make someone's day</div>
						</td>
						<td style='text-align:center; width:33%;'>
							<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/gold_cup_jbaj66.jpg'></div><br/>
								<div>Enjoy time with friends</div>
		</td>
					</tr>
				</table>
			</div><br/>
			<div style='text-align:center;'>
		#{ app_download_buttons_text }
					</div>
		</div>".html_safe
	end

	def text_for_invoice_giver gift
		receiver_info = gift.receiver_name
		if !gift.receiver_email.blank?
			receiver_info += " <p>email: " + gift.receiver_email + '</p>'
		elsif !gift.receiver_phone.blank?
			receiver_info += " <p>phone: " + number_to_phone(gift.receiver_phone) + '</p>'
		elsif !gift.facebook_id.blank?
			receiver_info += " <p>via facebook</p>"
		elsif !gift.twitter.blank?
			receiver_info += " <p>via twitter</p>"
		end
		"<table cellpadding='0' cellspacing='0' border='0' align='center' width='100%' class='devicewidth' style='width: 100%'>
<tbody><tr><td align='center' style='font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:14px;color:#404547;text-align:center;line-height: 150%;padding: 15px 10px;'>
<h2 style='line-height:33px;'>Thanks for gifting local with ItsOnMe!</h2>
<p>Your gift is being delivered to #{receiver_info}</p></td></tr><tr><td align='center'>
<table cellpadding='0' cellspacing='0' border='0' align='center' width='400' class='devicewidth' style='width:100%;max-width: 400px;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:14px;color:#404547;line-height: 150%;border: 1px solid #efefef;border-radius:4px;margin:15px 0'>
<tbody><tr><td style=' padding: 15px; border-bottom: 1px solid #efefef;'>Location</td>
<td style='text-align:right;padding: 15px;border-bottom: 1px solid #efefef;'>#{gift.merchant.name}</td>
</tr><tr><td style=' padding: 15px;border-bottom: 1px solid #efefef;'>Gift Value</td>
<td style='text-align:right;padding: 15px;border-bottom: 1px solid #efefef;'>#{gift.value_s}</td>
</tr><tr><td style=' padding: 15px;border-bottom: 1px solid #efefef;'>Processing Fee</td>
<td style='text-align:right;padding: 15px;border-bottom: 1px solid #efefef;'>#{gift.service_s}</td>
</tr><tr><td style=' padding: 15px;border-bottom: 1px solid #efefef;'><strong>Total</strong></td>
<td style='text-align:right;padding: 15px;border-bottom: 1px solid #efefef;'>#{gift.purchase_total}</td>
</tr></tbody></table></td></tr></tbody></table>".html_safe
	end

	def text_for_notify_receiver_wo_redemption gift
		image_url      = gift.merchant.image
		giver_image   = gift.giver.iphone_photo if gift.giver.class == "User"
		button_url    = "#{gift.invite_link}"
		button_text   = "Claim My Gift"
		giver_name    = gift.giver_name
					if gift.giver.class == "User"
					giver_image   = image_tag(gift.giver.iphone_photo, width: "50", height: "50")
					else
						giver_image   = image_tag('http://res.cloudinary.com/drinkboard/image/upload/v1410454300/avatar_blank.jpg', width: "50", height: "50")
					end
					provider_name = gift.provider_name
					expires_at    = make_ordinalized_date_with_day(gift.expires_at)
					details       = gift.detail
					"<div style=#{default_style}>
					#{header_text("You received a gift!")}
			<div style='padding: 0 100px 20px 100px;'>
				<div>
					<img src='#{image_url}' style='width: 400px;'>
				</div>
					#{items_text(gift)}
					#{button_text(button_url, button_text)}
			</div>
			<div style='background-color:#E2E2E2; padding: 10px;'>
				<table>
					<tr>
						<td style='width:15%; padding:10px;'>#{ giver_image }</td>
						<td style='width:70%;'>
							<div style='color:#8E8D8D'>#{ giver_name }</div>
							<div style='color:#3F3F3F;'>#{ gift.message }</div><br>
						</td>
						<td style='width:15%;'></td>
					</tr>
				</table>
					</div>
		</div>".html_safe
	end

	def text_for_notify_receiver_proto_join gift
		image_url      = gift.merchant.image
		button_url    = "#{gift.invite_link}"
		button_text   = "Claim My Gift"
		provider_name = gift.provider_name
		giver_name    = gift.giver_name ? gift.giver_name : provider_name
		giver_name_simple = giver_name.sub(" Staff", "")
		expires_at    = make_ordinalized_date_with_day(gift.expires_at)
		message       = gift.message
		details       = gift.detail
					"<div style=#{default_style}>
					#{header_text("You received a gift!")}
			<div style='padding: 0 100px 20px 100px;'>
				<div>
					<img src='#{image_url}' style='width: 400px;'>
				</div>
					#{items_text(gift)}
					#{button_text(button_url, button_text)}
			</div>
			<div style='padding:10px; font-size:16px;'>
				<ul style='list-style-type:none;'>
					<li>#{provider_name} has partnered with ItsOnMe!</li>
					<li>Claim your gift, simply click above & download the app.</li>
					<li>Use this email address at sign-up.</li>
					<li>- Thanks - ItsOnMe :)</li>
				</ul>
			</div>
			<div style='background-color:#E2E2E2; padding: 10px;'>
				<table>
					<tr>
						<td style='width:15%;'></td>
					<td style='width:70%; color:#3F3F3F;'>
					<div style='color:#8E8D8D'>The staff at #{giver_name_simple}</div>
							<div>#{message}</div><br>
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
					</div>
		</div>".html_safe
	end

	def text_for_notify_receiver gift
		image_url     = gift.merchant.get_photo
		giver_image   = gift.giver.iphone_photo if gift.giver.class == "User"
		button_url    = "#{gift.invite_link}"
		button_text   = "Claim My Gift"
		giver_name    = gift.giver_name
		if gift.giver.class == "User"
			giver_image   = image_tag(gift.giver.iphone_photo, width: "50", height: "50")
		else
			giver_image   = image_tag('http://res.cloudinary.com/drinkboard/image/upload/v1410454300/avatar_blank.jpg', width: "50", height: "50")
		end
		provider_name = gift.provider_name
		expires_at    = make_ordinalized_date_with_day(gift.expires_at)
		details       = gift.detail || ""
		redemption_method = v2_redemption
		case gift.merchant.r_sys
		when 1
			redemption_method = v1_redemption
		when 3
			redemption_method = pos_redemption
		end

		"<div style=#{default_style}>
					#{header_text("You received a gift!")}
			<div style='padding: 0 100px 20px 100px;'>
				<div>
					<img src='#{image_url}' style='width: 400px;'>
				</div>
					#{items_text(gift)}
					#{button_text(button_url, button_text)}
			</div>
			<div style='background-color:#E2E2E2; padding: 10px;'>
				<table>
					<tr>
						<td style='width:15%; padding:10px;'>#{ giver_image }</td>
						<td style='width:70%;'>
							<div style='color:#8E8D8D'>#{ giver_name }</div>
							<div style='color:#3F3F3F;'>#{ gift.message }</div><br>
						</td>
						<td style='width:15%;'></td>
					</tr>
					#{ detail_table_row(details, expires_at) }
				</table>
					</div>
					<hr style='border-bottom:1px solid #C9C9C9;'>
					#{redemption_method}
		</div>".html_safe
	end

	def text_for_affiliate_invite company, invite_token
		button_url = generate_affiliate_invite_link(invite_token)
		button_text = "Get Started"
					"<div style=#{default_style}>
					#{header_text("Welcome to ItsOnMe - Partner Tools")}
			<div style='padding: 0 80px 20px 80px; font-size:16px;'>
				<div style='padding-bottom:20px;'>
					You have been invited to ItsOnMe by #{company.name}!
				</div>
				<br />
				<div>
					Visit this link to create your account and review your account information.
					<br />
					Your ItsOnMe rep is available to answer any questions and walk you through your account.
				</div>
				<br />
			</div>
			<div>#{ button_text(button_url, button_text) }</div><br/>
			<div style='padding-top:30px;'>
		#{ merchant_values_text }
					</div>
		</div>".html_safe
	end

	def text_for_merchant_invite merchant, invite_token
		button_url = generate_invite_link(invite_token)
		button_text = "Get Started"
		"<div style=#{default_style}>
		#{header_text("Welcome to ItsOnMe")}
			<div style='padding: 0 80px 20px 80px; font-size:16px;'>
				<div style='padding-bottom:20px;'>
					You are almost ready to go live on ItsOnMe!
				</div>
				<br />
				<div>
					Visit this link to create your account and review your venue information.
					<br />
					Your ItsOnMe rep is available to answer any questions and walk you through your account.
				</div>
				<br />
			</div>
			<div>#{ button_text(button_url, button_text) }</div><br/>
			<div style='padding-top:30px;'>
		#{ merchant_values_text }
					</div>
		</div>".html_safe
	end

	def text_for_merchant_signup_welcome merchant_signup
		"<div style=#{default_style}>
		#{header_text("Welcome to ItsOnMe")}
			<div style='padding: 0 80px 20px 80px; font-size:16px;'>
				<br />
				<div style='padding-bottom:20px;'>
					Hi #{merchant_signup['name']},
				</div>
				<br />
		<div style='padding-bottom:20px;'>
		Thank you for your interest in ItsOnMe®!
		</div>
				<br />
		<div style='padding-bottom:20px;'>
					On 	<a href=#{ONE_SHEET_URL} target='_blank'
							style='color:#4C37FA;'>
							this one sheet
						</a>
					, you will see how ItsOnMe®:
				</div>
				<div>
					<ol>
						<li>Helps bars, restaurants and other local businesses sell
							more gift cards through increased distribution of
							their digital gifting menu.
						</li>
						<li>Accept digital gift cards with our industry leading POS
							integration which means zero training for management and staff.
						</li>
						<li>Updates marketing capabilities so a venue can drive new
							and existing customers to their business with no risk and
							no out of pocket cost.
						</li>
					</ol>
				</div>
				<div>
					<p>
						Your personal account representative will be in touch with you
						in the next 48 hours. We look forward to learning more about your
						business and how we can help it grow. If you have any questions
						please don’t hesitate to reach out.
					</p>
				</div>
				<br />
				<div style='padding-bottom:20px;'>
					Thank You,
				</div>
				<br />
				<div style='padding-bottom:20px;'>
					The ItsOnMe® Team
				</div>
			</div>
			<div style='padding-top:30px;'>
		#{ merchant_values_text }
					</div>
		</div>".html_safe
	end

	def text_for_merchant_staff_invite merchant, invitor_name, invite_token
		button_url = generate_invite_link(invite_token)
		button_text = "Get Started"
		"<div style=#{default_style}>
		#{header_text("Welcome to ItsOnMe")}
			<div style='padding: 0 80px 20px 80px; font-size:16px;'>
				<div style='padding-bottom:20px;'>
		#{invitor_name} added you as a user to #{merchant.name}'s ItsOnMe account.
				</div>
				<br/>
				<div>
					Visit the link to create your account.
				</div>
				<br>
			</div>
			<div>#{ button_text(button_url, button_text) }</div><br/>
			<div style='padding-top:30px;'>
		#{ merchant_values_text }
					</div>
		</div>".html_safe
	end

		def text_for_merchant_welcome merchant
			button_url = PUBLIC_URL_MT + '/login'
			button_text = "Get Started"
			"<div style=#{default_style}>
			#{header_text("Welcome to ItsOnMe")}
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px; text-align:center;'>
					<div>You are almost ready to go live on ItsOnMe!</div>
					<div>Visit this link to create your account and review your venue information.</div>
					<div>Your ItsOnMe rep is available to answer any questions and walk you through your account</div>
				</div>
			</div>
			<div style='padding-bottom: 50px;'>
			#{ button_text(button_url, button_text) }
			</div>
			<div>
			#{ merchant_values_text }
					</div>
		</div>".html_safe
	end

	def text_for_merchant_pending merchant
		button_url = PUBLIC_URL_MT + '/login'
		button_text = "Login"
		"<div style=#{default_style}>
		#{header_text("Pending Approval")}
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px; text-align:center;'>
					Thank you for completing your merchant account set-up
				</div>
				<div style='font-weight:bold; font-size:20px; text-align:center;'>
					What's Next?
				</div><br/>
				<table>
					<tr>
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_check_icon_drn49s.jpg'></td>
						<td>Your account rep will review your information and contact you within 48 hours.</td>
					</tr>
				</table><br/>
				<table>
					<tr>
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_X_icon_nstleh.jpg'></td>
						<td>Your rep will inform you if there is any missing account information that must be completed before going live.</td>
					</tr>
				</table>
			</div>
			<div>
		#{ button_text(button_url, button_text) }
					</div>
		</div>".html_safe
	end

	def text_for_merchant_approved merchant
		button_url = PUBLIC_URL_MT + '/login'
		button_text = "Login"
		"<div style=#{default_style}>
			<div style='width:100%; text-align:center;'>
						<div style='font-size:28px; padding-top:20px;''>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_location_icon_vnmf3j.jpg'></div>
					<div style='font-weight:bold;padding-top:10px'>Welcome</div>
					<div style='padding:10px;'>to the ItsOnMe family</div>
						</div>
				</div>
			<hr style='border-bottom:1px solid #C9C9C9;'>
			<div style='padding: 0 80px 20px 80px; color:#3F3F3F'>
				<div style='font-weight:bold; font-size:28px; text-align:center;'>
					What's Next?
				</div><br/>
				<table>
					<tr>
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_docs_icon_nuauo9.jpg'></td>
						<td><div>Train  your staff using the following materials. (Feel free to contact us if you have questions)</div></td>
					</tr>
					<tr>
						<td></td>
						<td>
							<ul>
								<li>
									<a href='https://www.dropbox.com/s/93tldku5puw3qno/training%20video1st%20draft.mov' target='_blank' style='color:#3F3F3F;'>
										Merchant Staff Training Video
									</a>
								</li>
								<li>
									<a href='http://www.itson.me/redemption' target='_blank' style='color:#3F3F3F;'>
										Staff Redemption One Sheets
									</a> (Print out and hand out)
								</li>
								<li>
									<a href='http://www.itson.me/preshift' target='_blank' style='color:#3F3F3F;'>
										Pre-Shift Document
									</a> (You can read off and hand out)
								</li>
								<li>
									<a href='http://screencast.com/t/GkAcdwWwn5FS' target='_blank' style='color:#3F3F3F;'>
										Merchant Tools Tour!
									</a> Check Orders and Send Gifts
								</li>
							</ul>
						</td>
					</tr>
				</table><br/>
				<table>
					<tr>
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_clock_icon_cyewpv.jpg'></td>
						<td>Your account rep will contact you shortly to set your go-live date.</td>
					</tr>
				</table>
			</div>
			<div style='padding:10px;'>
						#{ button_text(button_url, button_text) }
					</div>
		</div>".html_safe
	end

	def text_for_merchant_live merchant
		button_url = PUBLIC_URL_MT + '/login'
		button_text = "Login"
		"<div style=#{default_style}>#{header_text("#{merchant.name} is live!")}
<div style='padding: 0 80px 20px 80px;'><div style='padding-bottom:20px; font-size:16px;'>
#{merchant.name} is live on ItsOnMe. Login to your merchant center to accept digital gift cards, reward loyal customers, and drive new revenue.
</div><div>Need help? Email us at<a href='mailto:merchant@itson.me' target='_blank' style='color:#3F3F3F; text-decoration:underline;'>
merchant@itson.me</a><br /></div><br /></div><div>#{ button_text(button_url, button_text) }</div><br/><div style='padding-top:30px;'>#{ merchant_values_text }</div></div>".html_safe
	end

	def items_text gift
		"<table style='padding:0;'><tr><td width='320px' style='text-align:left'><div style='font-size:25px; padding-top:10px;'>$#{gift.value} Gift at #{gift.provider_name}</div></td></tr><tr><td><div style='font-size:15px; color:#8E8D8D;'>Gift Expires: #{make_date_s(gift.expires_at)}</div></td></tr><tr style='height: 100px;'><td style='text-align: left; font-size: 15px;'>#{GiftItem.items_for_email(gift)}</td></tr></table>".html_safe
	end

private

	def detail_table_row(details, expires_at)
		table_row = ""
		if details.length > 3
			table_row = "<tr>
				<td style='width:15%;'></td>
				<td style='width:70%;'>
					<div style='color:#8E8D8D'>Details</div>
					<div>This gift expires on #{expires_at}.</div>
					<div>#{details}</div>
				</td>
			</tr>"
		end
		table_row
	end

	def v1_redemption
		"<div style='background-color:#E2E2E2; width:100%; text-align:center;'><div style='color:#3F3F3F; font-size:20px; padding:15px 0 10px 0;''><div>How to redeem this gift</div></div></div><div style='background-color:#E2E2E2; width:100%; text-align:center;'><div style='color:#3F3F3F; font-size:16px; padding:15px 0 10px 0;''><div>Order your items like you normally would.</div><div>When the bill arrives follow the steps below to use your gift.</div></div></div><div style='background-color:#E2E2E2; padding: 10px;'><table><tr><td style='width:33%;'>1. Click the Gift Center and open your gift</td><td style='width:33%;'>2. Click redeem on the gift</td><td style='width:34%;'>3. Show your phone to the cashier</td></tr><tr><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-1.jpg' style='width:100%;'></td><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-2.jpg' style='width:100%;'></td><td style='width:34%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-3.jpg' style='width:100%;'></td></tr></table></div><div style='background-color:#E2E2E2; padding: 10px;'><table><tr><td style='width:33%;'>4. The cashier will complete the redemption</td><td style='width:33%;'>5. The app will give the cashier an order number</td><td style='width:34%;'>6. The cashier will apply the gift value to your bill</td></tr><tr><td le='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-4.jpg' style='width:100%;'></td><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-5.jpg' style='width:100%;'></td><td style='width:34%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-6.jpg' style='width:100%;'></td></tr></table></div>"
	end

	def v2_redemption
		"<div style='background-color:#E2E2E2; width:100%; text-align:center;'><div style='color:#3F3F3F; font-size:20px; padding:15px 0 10px 0;''><div>How to redeem this gift</div></div></div><div style='background-color:#E2E2E2; width:100%; text-align:center;'><div style='color:#3F3F3F; font-size:16px; padding:15px 0 10px 0;''><div>Order your items like you normally would.</div><div>When the bill arrives follow the steps below to use your gift.</div></div></div><div style='background-color:#E2E2E2; padding: 10px;'><table><tr><td style='width:33%;'>1. Click the Gift Center and open your gift</td><td style='width:33%;'>2. Click redeem on the gift</td><td style='width:34%;'>3. The app will give you a redemption code</td></tr><tr><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-1.jpg' style='width:100%;'></td><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-2.jpg' style='width:100%;'></td><td style='width:34%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180910/redemption_help/V2/V2-3.jpg' style='width:100%;'></td></tr></table></div><div style='background-color:#E2E2E2; padding: 10px;'><table><tr><td style='width:33%;'>4. Write the redemption code on the ItsOnMe line item on your receipt</td><td style='width:33%;'>5. Give the receipt to your cashier and they will apply the gift value to your bill</td><td style='width:34%;'>&nbsp;</td></tr><tr><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180911/redemption_help/V2/V2-4.jpg' style='width:100%;'></td><td style='width:33%;'>&nbsp;</td><td style='width:34%;'>&nbsp;</td></tr></table></div>"
	end

	def pos_redemption
		"<div style='background-color:#E2E2E2; width:100%; text-align:center;'><div style='color:#3F3F3F; font-size:20px; padding:15px 0 10px 0;''><div>How to redeem this gift</div></div></div><div style='background-color:#E2E2E2; width:100%; text-align:center;'><div style='color:#3F3F3F; font-size:16px; padding:15px 0 10px 0;''><div>Order your items like you normally would.</div><div>When the bill arrives follow the steps below to use your gift.</div></div></div><div style='background-color:#E2E2E2; padding: 10px;'><table><tr><td style='width:33%;'>1. Click the Gift Center and open your gift</td><td style='width:33%;'>2. Click redeem on the gift</td><td style='width:34%;'>3. Find your check number on the receipt from the venue</td></tr><tr><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-1.jpg' style='width:100%;'></td><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180826/redemption_help/V1/V1-2.jpg' style='width:100%;'></td><td style='width:34%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180799/redemption_help/pos/POS-3.jpg' style='width:100%;'></td></tr></table></div><div style='background-color:#E2E2E2; padding: 10px;'><table><tr><td style='width:33%;'>4. Enter your receipt check number in the app</td><td style='width:33%;'>5. The app will update and confirm the gift was applied to your bill</td><td style='width:34%;'>6. Pay the remaining balance on your check and don’t forget to tip</td></tr><tr><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180800/redemption_help/pos/POS-4.jpg' style='width:100%;'></td><td style='width:33%;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1430180800/redemption_help/pos/POS-5.jpg' style='width:100%;'></td><td style='width:34%;'>&nbsp;</td></tr></table></div>"
	end

	def default_style
		"font-family:verdana; color:#3F3F3F;"
	end

	def header_text text
		"<div style='width:100%; text-align:center;'><div style='color:#3F3F3F; font-size:20px; padding:15px 0 10px 0;'><div>#{text}</div></div></div><hr style='border-bottom:1px solid #C9C9C9; padding: 0 5px;'>".html_safe
	end

	def button_text url, text
		"<div><div style='display:block; width: 200px; margin:auto;'><a href='#{url}' style='color:white; text-decoration:none;background-color:#42C2E8; display: block; padding: 10px 0; text-align:center; border-bottom:2px solid #2B99BB; border-radius: 3px; font-size:20px;'>#{text}</a></div></div>".html_safe
	end

	def app_download_buttons_text
		"<div>
		<a href='https://itunes.apple.com/us/app/drinkboard-mobile-gifting/id659661295' target='_blank'>
		<img src='http://gallery.mailchimp.com/d7952b3f9c7215024f55709cf/images/0ef011d7-25b6-4a92-894d-a42376893dcf.jpg'>
		</a>
		<a href='https://play.google.com/store/apps/details?id=com.fbg.drinkboard&hl=en' target='_blank'>
				<img src='http://gallery.mailchimp.com/d7952b3f9c7215024f55709cf/images/f4936d42-c3b7-49f8-adf1-cdf48166a3ed.jpg'>
		</a>
		</div>".html_safe
	end

	def merchant_values_text
		"<table style='width: 100%;'>
			<tr>
				<td style='text-align:center; width:33%;'>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/green_check_icon_jgf7qu.jpg'></div><br/>
					<div>Track gift redemptions</div>
				</td>
				<td style='text-align:center; width:33%;'>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/green_gift_baocpx.jpg'></div><br/>
					<div>Drive customers</div>
				</td>
				<td style='text-align:center; width:33%;'>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/green_money_q1mott.jpg'></div><br/>
					<div>Increase revenue</div>
				</td>
			</tr>
		</table>"
	end

	def generate_affiliate_invite_link invite_token
		"#{PUBLIC_URL_PT}/invites?token=#{invite_token}"
	end

	def generate_invite_link invite_token
		"#{PUBLIC_URL_MT}/invites?token=#{invite_token}"
	end

end
