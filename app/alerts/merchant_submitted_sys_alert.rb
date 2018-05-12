class MerchantSubmittedSysAlert < Alert


#   -------------

	def text_msg
		get_data
		"#{name_string}\n#{@data}"
	end

	def email_msg
		get_data
		"<div><h2>#{name_string}</h2><p>#{@data}</p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
        title = "New merchant signup:\n"

        merchant_submit_obj = @target
		if merchant_submit_obj.kind_of?(MerchantSignup)
            @data = title + merchant_submit_obj.email_body
		else
			@data = title + merchant_submit_obj.inspect
	        if merchant_submit_obj["id"].to_i > 0
	            if signup_obj = MerchantSignup.where(id: merchant_submit_obj["id"]).first
                    @data = title + signup_obj.email_body
	            end
	        end
		end
	end

end

__END__

    def mail_notice_submit_merchant_setup merchant_submit_obj
        puts "MerchantSignup Email #{merchant_submit_obj.inspect}"
        subject = "#{merchant_submit_obj['venue_name']} has requested to join"
        signup_obj = nil
        text = "Please login to Admin Tools create account for:\n#{merchant_submit_obj}"

        if merchant_submit_obj["id"].present? && merchant_submit_obj["id"].to_i > 0
            signup_obj = MerchantSignup.find(merchant_submit_obj["id"])
            if signup_obj
                text = "Please login to Admin Tools create account for:\n#{signup_obj.email_body}"
            end
        end

        message = { :subject=> subject_creator(subject),
                    :from_name=> "Merchant Tools",
                    :text => text,
                    :to=> HELP_CONTACT_ARY,
                    :from_email => NO_REPLY_EMAIL
        }
        request_mandrill_with_message(message).first
    end

