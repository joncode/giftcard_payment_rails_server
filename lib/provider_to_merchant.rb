class ProviderToMerchant

	attr_reader :diffs, :compare, :no_providers

	def initialize

		@compare = [ "name","zinger","description","city_name","state","zip","phone","active","rate","token","image","live","paused","pos_merchant_id","region_id","r_sys","photo_l","payment_event","tender_type_id","website","city_id","region_name" ]
		@no_providers = []
		@diffs = []

	end


	def start

		ms = Merchant.unscoped.all;nil

		ms.each do |m|
			p = Provider.unscoped.where(merchant_id: m.id).first
			if p.nil?
				@no_providers << m
				next
			end

			m.menu_is_live = p.menu_is_live
			m.brand_id = p.brand_id
			m.building_id = p.building_id
			m.tools = p.tools
			m.payment_plan = p.payment_plan

			@compare.each do |c|

				# puts c.inspect

				m_field = m.send(c)
				p_field = p.send(c)

				if m_field != p_field && p_field.present?

					# convering all the nils and blanks
					# puts m_field
					# puts p_field

					if m_field.blank? && !p_field.blank?
						m.send("#{c}=", p_field)
					elsif p_field.kind_of?(String) && p_field.match(m_field) && m_field[0...2] == 'd|'
						# updating the photos
						m.send("#{c}=", p_field)
					elsif c == 'address'

					end


					if m.send(c) != p.send(c) && p.send(c).present?

						@diffs << [c, m.name, m.id, p.id, m_field, p_field]
					end

				end
			end

			m.save
			nil
		end
		pp @diffs
		nil
	end

end

