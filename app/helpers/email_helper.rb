module EmailHelper
	include TimeHelper
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::AssetTagHelper


	def text_for_welcome_from_dave user
		string = "Hi #{ user.first_name },\n\n"
		string += "Welcome! I'm the CEO of It's On Me and wanted to welcome you and thank you for joining.\n"
		string += "It's On Me is the easiest way to say, 'Thank you, this round is on me.'\n\n"
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
					Welcome to It's On Me #{user_first_name}! Please click the link to confirm your email address.
				</div>
	            #{button_text(button_url, button_text)}
	        </div>
		</div>".html_safe
	end

	def text_for_user_reset_password user
		user_first_name = user.first_name
		if user.class == MtUser
			button_url  = "#{PUBLIC_URL_MT}/reset_password?token=#{user.reset_token}"
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
					<span><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/gold_celebrate_icon_hi074a.png'></span>
					<span>Celebrate</span>
	        	</div>
	    	</div>
			<hr style='border-bottom:1px solid #C9C9C9;'>
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px;'>
					<div>Hi #{user_first_name},</div><br/>
					<div>It's a good day to make someone happy. Use It's On Me to send a gift and say you're awesome, congrats, or thank you.</div>
				</div>
			</div>
			<div style='padding-bottom:50px;'>
				<table style='width: 100%;'>
					<tr>
						<td style='text-align:center; width:33%;'>
							<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/gold_heart_zzd8mq.png'></div><br/>
								<div>Find something new to love</div>
						</td>
						<td style='text-align:center; width:33%;'>
							<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1410563975/gold_gift_su2ced.png'></div><br/>
								<div>Make someone's day</div>
						</td>
						<td style='text-align:center; width:33%;'>
							<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/gold_cup_jbaj66.png'></div><br/>
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
		if gift.receiver_name
			receiver_info = gift.receiver_name
		elsif gift.receiver_email
			receiver_info = gift.receiver_name
		elsif gift.receiver_phone
			receiver_info = gift.receiver_name
		else
			receiver_info = gift.receiver_name
		end
		"<div style=#{default_style}>
			<div style='width:100%; text-align:center;'>
	        	<div style='color:#3F3F3F; font-size:30px; font-weight:lighter;'>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946711/receipt-header_hnqrpi.png'></div><br/>
					<div>Makin' it rain.</div>
	        	</div>
	    	</div>
			<hr style='border-bottom:1px solid #C9C9C9;'>
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px; text-align:center;'>
					Your gift is being delivered to #{receiver_info}
				</div>
				<table style='width: 100%;'>
					<tr>
						<td style='text-align:right; padding: 0 10px; width:50%;'>Location</td>
						<td style='text-align:left; width:50%;'>#{gift.provider.name}</td>
					</tr>
					<tr>
						<td style='text-align:right; padding: 0 10px; width:50%;'>Gift value</td>
						<td style='text-align:left; width:50%;'>#{number_to_currency(gift.value)}</td>
					</tr>
					<tr>
						<td style='text-align:right; padding: 0 10px; width:50%;'>Processing fee</td>
						<td style='text-align:left; width:50%;'>#{number_to_currency(gift.service)}</td>
					</tr>
					<tr style='font-weight:bold;'>
						<td style='text-align:right; padding: 0 10px; width:50%;'>Total</td>
						<td style='text-align:left; width:50%;'>#{number_to_currency(gift.grand_total)}</td>
					</tr>
				</table>
	        </div>
		</div>".html_safe
	end

	def text_for_notify_receiver gift
		image_url      = gift.provider.image
		giver_image   = gift.giver.iphone_photo if gift.giver.class == "User"
		button_url    = "#{PUBLIC_URL}/signup/acceptgift?id=#{NUMBER_ID + gift.id}"
		button_text   = "Claim My Gift"
		giver_name    = gift.giver_name
		if gift.giver.class == "User"
			giver_image   = image_tag(gift.giver.iphone_photo, width: "50", height: "50")
		else
			giver_image   = image_tag('http://res.cloudinary.com/drinkboard/image/upload/v1410454300/avatar_blank.png', width: "50", height: "50")
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
				<div style='padding-bottom:20px; font-size:16px;'>
					#{provider_name} has partnered with It's On Me to deliver this gift to some of its favorite customers. To claim this gift simply click the button and download the app. Use this email address at sign-up to receiver your gift.
				</div>
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
		image_url      = gift.provider.image
		button_url    = "#{PUBLIC_URL}/signup/acceptgift?id=#{NUMBER_ID + gift.id}"
		button_text   = "Claim My Gift"
		provider_name = gift.provider_name
		giver_name    = gift.giver_name ? gift.giver_name : provider_name
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
					<li>#{provider_name} has partnered with It's On Me!</li>
					<li>Claim your gift, simply click above & download the app.</li>
					<li>Use this email address at sign-up.</li>
					<li>- Thanks - It's On Me :)</li>
				</ul>
			</div>
			<div style='background-color:#E2E2E2; padding: 10px;'>
				<table>
					<tr>
						<td style='width:15%;'></td>
						<td style='width:70%; color:#3F3F3F;'>
							<div style='color:#8E8D8D'>The staff at #{giver_name}</div>
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

	def text_for_merchant_invite merchant, invite_token
		button_url = generate_invite_link(invite_token)
		button_text = "Get Started"
		"<div style=#{default_style}>
			#{header_text("Welcome to It's On Me")}
			<div style='padding: 0 80px 20px 80px; font-size:16px;'>
				<div style='padding-bottom:20px;'>
					This is your first step to going live.
				</div><br/>
				<div>
					Visit the link to create your account.
				</div><br>
			</div>
			<div>#{ button_text(button_url, button_text) }</div><br/>
			<div style='padding-top:30px;'>
				#{ merchant_values_text }
	        </div>
		</div>".html_safe
	end

	def text_for_merchant_staff_invite merchant, invitor_name, invite_token
		button_url = generate_invite_link(invite_token)
		button_text = "Get Started"
		"<div style=#{default_style}>
			#{header_text("Welcome to It's On Me")}
			<div style='padding: 0 80px 20px 80px; font-size:16px;'>
				<div style='padding-bottom:20px;'>
					#{invitor_name} added you as a user to #{merchant.name}'s It's On Me account.
				</div><br/>
				<div>
					Visit the link to create your account.
				</div><br>
			</div>
			<div>#{ button_text(button_url, button_text) }</div><br/>
			<div style='padding-top:30px;'>
				#{ merchant_values_text }
	        </div>
		</div>".html_safe
	end

	def text_for_merchant_welcome merchant
		button_url = PUBLIC_URL_MT
		button_text = "Get Started"
		"<div style=#{default_style}>
			#{header_text("Welcome to It's On Me")}
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px; text-align:center;'>
					<div>This is your first step to going live.</div>
					<div>Visit this link to create your merchant account.</div>
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
		button_url = PUBLIC_URL_MT
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
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_check_icon_drn49s.png'></td>
						<td>Your account rep will review your information and contact you within 48 hours.</td>
					</tr>
				</table><br/>
				<table>
					<tr>
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_X_icon_nstleh.png'></td>
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
		button_url = PUBLIC_URL_MT
		button_text = "Login"
		"<div style=#{default_style}>
			<div style='width:100%; text-align:center;'>
	        	<div style='font-size:28px; padding-top:20px;''>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_location_icon_vnmf3j.png'></div>
					<div style='font-weight:bold;padding-top:10px'>Welcome</div>
					<div style='padding:10px;'>to the It's On Me family</div>
	        	</div>
	    	</div>
			<hr style='border-bottom:1px solid #C9C9C9;'>
			<div style='padding: 0 80px 20px 80px; color:#3F3F3F'>
				<div style='font-weight:bold; font-size:28px; text-align:center;'>
					What's Next?
				</div><br/>
				<table>
					<tr>
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_docs_icon_nuauo9.png'></td>
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
						<td style='width:60px;'><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946702/blue_clock_icon_cyewpv.png'></td>
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
		button_url = PUBLIC_URL_MT
		button_text = "Login"
		"<div style=#{default_style}>
			#{header_text("#{merchant.name} is live!")}
			<div style='padding: 0 80px 20px 80px;'>
				<div style='padding-bottom:20px; font-size:16px;'>
					#{merchant.name} is live on It's On Me. Login to your merchant center to accept digital gift cards, reward loyal customers, and drive new revenue.
				</div>
				<div>
					Need help? Email us at
					<a href='mailto:merchant@itson.me' target='_blank' style='color:#3F3F3F; text-decoration:underline;'>
						merchant@itson.me
					</a><br>
				</div><br>
			</div>
			<div>#{ button_text(button_url, button_text) }</div><br/>
			<div style='padding-top:30px;'>
				#{ merchant_values_text }
	        </div>
		</div>".html_safe
	end

	def items_text gift
		"<table style='padding:0;'>
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
				<td style='text-align: left; font-size: 15px;'>
					#{GiftItem.items_for_email(gift)}
				</td>
			</tr>
		</table>".html_safe
	end

private

	def default_style
		"font-family:verdana; color:#3F3F3F;"
	end

	def header_text text
		"<div style='width:100%; text-align:center;'>
        	<div style='color:#3F3F3F; font-size:20px; padding:15px 0 10px 0;''>
				<div>#{text}</div>
        	</div>
    	</div>
		<hr style='border-bottom:1px solid #C9C9C9;'>"
	end

	def button_text url, text
		"<div>
			<div style='display:block; width: 200px; margin:auto;'>
				<a href='#{url}' style='color:white; text-decoration:none;background-color:#42C2E8; display: block; padding: 10px 0; text-align:center; border-bottom:2px solid #2B99BB; border-radius: 3px; font-size:20px;'>
				#{text}
				</a>
			</div>
		</div>".html_safe
	end

	def app_download_buttons_text
		"<div>
			<a href='https://itunes.apple.com/us/app/drinkboard-mobile-gifting/id659661295' target='_blank'>
				<img src='http://gallery.mailchimp.com/d7952b3f9c7215024f55709cf/images/0ef011d7-25b6-4a92-894d-a42376893dcf.png'>
			</a>
			<a href='https://play.google.com/store/apps/details?id=com.fbg.drinkboard&hl=en' target='_blank'>
				<img src='http://gallery.mailchimp.com/d7952b3f9c7215024f55709cf/images/f4936d42-c3b7-49f8-adf1-cdf48166a3ed.png'>
			</a>
		</div>".html_safe
	end

	def merchant_values_text
		"<table style='width: 100%;'>
			<tr>
				<td style='text-align:center; width:33%;'>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/green_check_icon_jgf7qu.png'></div><br/>
					<div>Track gift redemptions</div>
				</td>
				<td style='text-align:center; width:33%;'>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/green_gift_baocpx.png'></div><br/>
					<div>Drive customers</div>
				</td>
				<td style='text-align:center; width:33%;'>
					<div><img src='http://res.cloudinary.com/drinkboard/image/upload/v1409946703/green_money_q1mott.png'></div><br/>
					<div>Increase revenue</div>
				</td>
			</tr>
		</table>"
	end

	def generate_invite_link invite_token
		"#{PUBLIC_URL_MT}/invite?token=#{invite_token}"
	end

end
