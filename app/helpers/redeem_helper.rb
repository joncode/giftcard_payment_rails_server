module RedeemHelper

    def reset_time
        time_now = Time.now.utc
        rt = time_now.beginning_of_hour.change(hour: 14)
        if time_now < rt
            rt - 1.day
        else
            rt
        end
    end

    def make_order_num(obj_id)
        number   = obj_id + 1500
        div      = number / 26
        letter2  = number_to_letter(number % 26)
        div2     = div / 10000
        numbers  = make_numbers(div)
        over     = div2 / 26
        letter1  = number_to_letter(div2 % 26)
        return "#{letter1.to_s}#{letter2.to_s}#{numbers.to_s}"
    end

private

    def make_numbers(div)
        num = "%04d" % (div % 10000)
        "-#{num[3]}#{num[0]}-#{num[2]}#{num[1]}"
    end

    def number_to_letter(num)
        return (num + 10).to_s(36).capitalize
    end

end