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
        subject       = "#{@gift.giver_name} sent you a @gift"

        template_name = "Gift: 08.2015 New Template Play"
        pteg_affiliate_id = Rails.env.staging? ? 20 : 29
        if @gift.partner_type == 'Affiliate' && @gift.partner_id == pteg_affiliate_id
            template_name = 'gift-pteg'
        end
        puts template_name
        message       = make_dynamic_variables(subject, email)
        request_mandrill_with_template(template_name, message, [@gift.id, "Gift"])
    end

############ PRIVATE

    def make_dynamic_variables(subject, email)
        merchant = @gift.merchant
        if merchant.nil?
            puts 'NO Merchant - make_dynamic_variables'
            return nil
        end
        email = whitelist_email(email)
        message          = {
            "subject"     => subject,
            "from_name"   => "It's On Me",
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
                { "name" => "gift_detail", "content" => blank_merge_var(@gift.detail) },
                {'name' => 'expiration', 'content' => expired_merge_var(@gift.expires_at) }
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
        str + mp_str
        # http://res.cloudinary.com/drinkboard/image/upload/b_rgb:0d0d0d,bo_0px_solid_rgb:000,c_crop,co_rgb:090909,h_180,o_40,q_100,w_600/v1439771625/email_elements/littleOwl_bgImg_hdr.jpg
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
