class Forensic

	attr_reader :err

	def initialize gift
		@err = {}
		sale_ccy(gift)
		sale_total(gift)
	end






	def sale_total gift
		p = gift.payable

	end


	def sale_ccy gift
		p = gift.payable
		if gift.ccy != p.ccy
			@err[:sale_ccy] = "#{gift.ccy} does not == #{p.ccy}"
		end
	end


#   -------------


	def self.sales
		n = []
		e = []
		c = []
		Sale.all.find_each do |s|
			if s.revenue.nil? || s.revenue_cents.nil?
				n << s
			else
				if (s.revenue * 100).to_i != s.revenue_cents
					e << s
				end
			end
			if s.ccy != 'USD' && s.gateway != 'authorize' && s.revenue_cents != 0 && s.resp_code == 1
				if s.usd_cents == s.revenue_cents
					c << s
				end
			end
		end
		{ err: e, none: n, ccy: c }
	end


end