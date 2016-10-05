class BoomerangMailer
	include Emailer

	attr_reader :gift, :bcc

	def initialize(gift_id)
		@gift = GiftBoomerang.find(gift_id)
		@bcc  = "info@itson.me"
	end

    def notify_receiver
        original_receiver = @gift.original_receiver_social

        template_name    = "iom-boomerang-notice-2"
        recipient_name   = @gift.receiver_name
        if @gift.receiver_email
            email         = @gift.receiver_email
        elsif @gift.receiver
            email         = @gift.receiver.email
        else
            puts "NOTIFY RECEIVER BOOMERANG CALLED WITHOUT RECEIVER EMAIL"
            return nil
        end

        items_text       = items_text(gift)
        template_content = [
            { "name" => "items_text", "content" => items_text },
            { "name" => "original_receiver", "content" => original_receiver}]
        message          = make_dynamic_variables(email, recipient_name)
        request_mandrill_with_template(template_name, message, [@gift.id, "Gift"], template_content)
    end

############ PRIVATE

    def items_text gift
        expiration_row = ""
        if gift.expires_at.present?
            expiration_row = "<tr><td><div style='font-size:15px; color:#8E8D8D;'>Gift Expires: #{make_date_s(gift.expires_at)}</div></td></tr>"
        end
        "<table style='padding:0;'><tr><td width='320px' style='text-align:left'><div style='font-size:25px; padding-top:10px;'>
#{gift.value_s} Gift at #{gift.merchant_name}</div></td></tr>#{expiration_row}<tr style='height: 100px;'>
<td style='text-align: left; font-size: 15px;'>#{GiftItem.items_for_email(gift)}</td></tr></table>".html_safe
    end

    def make_dynamic_variables(email, name)
        email = whitelist_email(email)
        message = {
            "subject"     => "Boomerang! We're returning this gift to you.",
            "from_name"   => "#{SERVICE_NAME}",
            "from_email"  => "#{NO_REPLY_EMAIL}",
            "to"          => [{ "email" => email, "name" => name }],
            "bcc_address" => @bcc,
            "merge_vars"  =>[
                {
                    "rcpt" => email,
                    "vars" => [{"name" => "link", "content" => "#{@gift.invite_link}"}]
                }
            ]
        }
        message
    end

end
