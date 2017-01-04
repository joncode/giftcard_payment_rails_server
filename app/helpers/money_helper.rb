module MoneyHelper
	include  ActionView::Helpers::NumberHelper

	# money is a string with cents when there are cents , otherwise just dollar
	# ie.  "8.50"  or "8" - but not "8.5" or "8.00"

	# currency is money with a $ or other ccy symbol

	def cents_to_words(cents, ccy='USD')
		amt = cents
		dollars = amt/100.0
		if dollars == dollars.to_i
			# no cents
			"#{dollars.to_i.to_words.titleize} #{CCY[ccy]['name'].pluralize(dollars.to_i)}"
		else
			ary = flo.to_s.split(CCY[ccy]["decimal_mark"])
			dollars = ary[0].to_i
			cents = ary[1].to_i
			"#{dollars.to_words.titleize} #{CCY[ccy]['name'].pluralize(dollars)} & #{cents.to_words.titleize} #{CCY[ccy]['subunit'].pluralize(cents)}"
		end
	end

 	def string_to_float str
 		str.to_f.round(2)
 	end

	def float_to_money float, ccy: nil
		display_money dollar_f: float.to_f, ccy: ccy
	end

	def string_to_money str, ccy: nil
		display_money string: str, ccy: ccy
	end

	def display_money cents: nil, ccy: nil, zeros: false, dollar_f: nil, string: nil
		value = if cents.present?
			cents
		elsif dollar_f.present?
			dollar_f * 100
		elsif string.present?
			string_to_float(string) * 100
		else
			cents
		end
		cents_to_currency value, !zeros, ccy
	end

    #### DO NOT CALL :cents_to_currency CALL :display_money INSTEAD
	def cents_to_currency cents, remove_zeros=true, ccy=nil
		return nil if cents.blank?
		new_str = number_to_currency(cents/100.0,  :format => "%n", :negative_format => "(%n)", delimiter: "")
		if remove_zeros
	        if new_str && new_str[-3..-1] == ".00"
	            new_str[-3..-1] = ""
	        end
	    end
		if ccy
			CCY[ccy]['symbol'] + new_str
		else
			new_str
		end
	end

	def currency_to_cents currency_str
		return nil if currency_str.blank?
		amount = remove_currency_symbol(currency_str)
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

	def remove_currency_symbol currency_str
		return currency_str unless currency_str.kind_of?(String)
		currency_str.gsub(/[^0-9.]/, '')
	end

end




