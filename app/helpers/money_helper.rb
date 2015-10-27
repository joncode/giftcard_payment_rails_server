module MoneyHelper
  include  ActionView::Helpers::NumberHelper

  # moeny is a string with cents when there are cents , otherwise just dollar
  # ie.  "8.50"  or "8" - but not "8.5" or "8.00"

  # currency is money with a $


    def float_to_money float
        string_to_money float.to_s
    end

    def string_to_money str
        new_str = number_to_currency(str,  :format => "%n", :negative_format => "(%n)")
        if new_str && new_str[-3..-1] == ".00"
            new_str[-3..-1] = ""
        end
        new_str
    end

    def cents_to_currency cents
        return nil if cents.blank?
        new_str = number_to_currency(cents/100.0,  :format => "%u%n", :negative_format => "(%u%n)")
        if new_str && new_str[-3..-1] == ".00"
            new_str[-3..-1] = ""
        end
        new_str
    end

    def currency_to_cents currency_str
        amount = currency_str.gsub('$', '')
        amount = amount.split('.')
        if amount.count == 2
            cents = amount[1]
            if cents.length == 1
                amount[1] = cents.to_s + '0'
            end
            amount = amount.join('').to_i
        else
            amount = amount[0].to_i * 100
        end
        amount
    end

end