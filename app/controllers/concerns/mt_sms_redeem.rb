module MtSmsRedeem
    extend ActiveSupport::Concern


    def get_mt_user_with_number mt_user_number

    	n = mt_user_number.gsub!(/[^0-9]/, '')
    	n[0] = '' if n[0] == '1'
    	mtu = MtUser.get_phone_notification(n)
    end

    def find_gift_if_mt_user_has_notified_gifts(mt_user, code)
    	Gift.find_gift_for_mt_user_and_code(mt_user.id, code)
    end









end