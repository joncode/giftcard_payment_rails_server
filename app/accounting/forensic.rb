class Forensic

	def self.gifts
		Gift.includes(:registers).all.find_each do |g|

			regs = gift.registers

			total = Register.sum_gift(regs)

		end
	end

	def self.registers
		c = []

		Register.all.find_each do |r|
			errored = nil

			if r.ccy.nil?
				errored = true
				c << r
			end



		end
	end


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
		# err is for when revenue != revenue_cents -- this no longer matters because revenue is not used
		# none is when sale revenue_cents is nil -
		# ccy is when sales is not usd but not converted to usd
		# miss is when ccy is missing
		# wrong is when gift ccy != sale ccy
		{ err: e, none: n, ccy: c, miss: m, wrong: wccy }
	end


end