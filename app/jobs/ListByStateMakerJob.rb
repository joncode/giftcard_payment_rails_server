class ListByStateMakerJob

	def self.perform
		puts "ListByStateMakerJob START"
		mhsh = {}
		nona = []
		ms = M.where(active: true, live: true, paused: false).find_each do |m|
			next if m.zip.match '11111'
			if CANADIAN_HSH[m.state].present?
				# Canadian merchant
				if mhsh[m.state].nil?
					mhsh[m.state] = { country: 'CA', type: 'province' , abbr: m.state, name: CANADIAN_HSH[m.state], ms: [] }
				end
				mhsh[m.state][:ms] << m
			elsif USA_HSH[m.state].present?
				# USA merchant
				if mhsh[m.state].nil?
					mhsh[m.state] = { country: 'US', type: 'state' , abbr: m.state, name: USA_HSH[m.state], ms: [] }
				end
				mhsh[m.state][:ms] << m
			else
				# non - US, non - CA merchant
				nona << m
			end
		end; nil

		mhsh.each do | k , v |

			name = "#{v[:country]} #{v[:type].capitalize} - #{v[:name]}"
			l = List.find_or_create_by( name: name, item_type: 'merchant', active: true )
			puts l.errors.messages

			l.list_graphs.each do |lg|
				m = lg.item
				if !m.active || !m.live || m.paused || m.zip.match('11111')
					lg.destroy
				end
			end

			ms = v[:ms]
			ms.sort_by! {|m| m.name }

			ms.each do |m|

				lg = ListGraph.new(item_id: m.id, item_type: m.class.to_s)
				l.list_graphs << lg

			end
		end; nil
		puts "ListByStateMakerJob END"
	end


end