class GiftTemplateMainMailer
	include Emailer

	attr_reader :gift, :bcc

	def initialize(gift_id)
		@gift = Gift.find(gift_id)
		@bcc  = nil
	end

    def notify_receiver
        if @gift.receiver_email
            email     = @gift.receiver_email
        elsif @gift.receiver
            email     = @gift.receiver.email
        else
            puts "NOTIFY RECEIVER CALLED WITHOUT RECEIVER EMAIL"
            return nil
        end
        subject = "#{@gift.giver_name} sent you a Gift!"

        if Rails.env.staging?
            template_name = "new-gift-notification-071316"
            pteg_affiliate_id = 20
        else
            template_name = "basic_simple_42-revised"
            pteg_affiliate_id = 29
        end
        if @gift.partner_type == 'Affiliate' && @gift.partner_id == pteg_affiliate_id
            template_name = 'gift-pteg'
        end
        puts template_name
        message = make_dynamic_variables(subject, email, template_name)
        request_mandrill_with_template(template_name, message, [@gift.id, "Gift"])
    end

############ PRIVATE

    def make_dynamic_variables(subject, email, template_name)
        merchant = @gift.merchant
        if merchant.nil?
            puts 'NO Merchant - make_dynamic_variables'
            return nil
        end
        if template_name == 'gift-pteg'
            from_name = "Pt's Entertainment Group via ItsOnMe"
        else
            from_name = "ItsOnMe"
        end
        email = whitelist_email(email)
        if @gift.receiver_email && !@gift.receiver_id
            email_rec_name = @gift.receiver_email
        else
            email_rec_name = @gift.receiver_name
        end

        if @gift.giver_type == "User" && @gift.receiver_id.nil?
            important_msg = "<span style='color:#23a9e1;'>Important: </span> Claim this gift within 14 days or it will be returned to sender.".html_safe
        elsif @gift.expires_at.present?
            important_msg = "<span style='color:#23a9e1;'>Important: </span> This gift will expire. Please claim and use before #{make_date_s(@gift.expires_at)}. #{@gift.detail}".html_safe
        else
            important_msg = "Enjoy and have fun!".html_safe
        end

        message          = {
            "subject"     => subject,
            "from_name"   => from_name,
            "from_email"  => "no-reply@itson.me",
            "to"          => [
                { "email" => email, "name" => @gift.receiver_name }
            ],
            "global_merge_vars" => [
                { "name" => "merchant_email_adjusted_photo", "content" => merchant_email_adjusted_photo(merchant.get_photo) },
                { "name" => "gift_id", "content" => @gift.obscured_id },
                { "name" => "message", "content" => blank_merge_var(@gift.message) },
                { "name" => "merchant_name", "content" => merchant.name },
                { "name" => "merchant_address", "content" => merchant.complete_address },
                { "name" => "gift_items", "content" => GiftItem.items_for_email(@gift) },
                { "name" => "gift_detail", "content" => gift_detail_var(@gift.detail) },
                { 'name' => 'expiration', 'content' => expired_merge_var(@gift.expires_at) },
                { 'name' => 'receiver_name', 'content' => email_rec_name },
                { 'name' => 'giver_name', 'content' => @gift.giver_name },
                { 'name' => 'important', 'content' => important_msg },
                { 'name' => 'gift_link', 'content' => @gift.invite_link },
                { 'name' => 'paper_id', 'content' => @gift.paper_id }
            ]
        }

        puts message
        if @bcc.present?
            message["to"] << { "email" => @bcc, "name" => @bcc, "type" => "bcc" }
        end
        if merchant.name.present?
            message["tags"] = [merchant.name]
        end
        message
    end

    def merchant_email_adjusted_photo merchant_photo_url
        str = 'http://res.cloudinary.com/drinkboard/image/upload/b_rgb:0d0d0d,bo_0px_solid_rgb:000,c_crop,co_rgb:090909,h_180,o_40,q_100,w_600'
        mp_str = merchant_photo_url.split('upload')[1]
        # puts (str + mp_str)
        str + mp_str.to_s
        # http://res.cloudinary.com/drinkboard/image/upload/b_rgb:0d0d0d,bo_0px_solid_rgb:000,c_crop,co_rgb:090909,h_180,o_40,q_100,w_600/v1439771625/email_elements/littleOwl_bgImg_hdr.jpg
    end

    def gift_detail_var(str)
        if str.blank?
            ""
        else
           "<div style='visibility:visible;font-size:12px;'>#{str}</div>"
        end
    end

    def blank_merge_var(str)
        if str.blank?
            "&nbsp;".html_safe
        else
            str
        end
    end

    def expired_merge_var(datetime_string)
        if datetime_string.blank?
            "&nbsp;".html_safe
        else
            "<div style='font-size:15px; color:#8E8D8D;'>Gift Expires: #{make_date_s(datetime_string)}</div>".html_safe
        end
    end


end
