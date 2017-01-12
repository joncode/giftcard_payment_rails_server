class Forensic




#   -------------


	def self.sales
		n = []
		e = []
		c = []
		m = []
		wccy = []
		Sale.all.find_each do |s|
			errored = nil
			if s.ccy.nil?
				errored = true
				m << s
			end
			if (s.revenue.nil? || s.revenue_cents.nil?)
				if s.resp_code == 1
					errored = true
					n << s
				end
			else
				if (s.revenue * 100).to_i != s.revenue_cents
					errored = true
					e << s
				end
			end
			if s.ccy != 'USD' && s.gateway != 'authorize' && s.revenue_cents != 0 && s.resp_code == 1
				if s.usd_cents == s.revenue_cents
					errored = true
					c << s
				end
			end
			if errored.nil?
				g = s.get_gift
				wccy << s if !g.nil? && g.ccy != s.ccy
			end
		end
		{ err: e, none: n, ccy: c, miss: m, wrong: wccy }
	end


end