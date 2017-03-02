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

	def self.recents

		mhsh = {}
		itemhsh = {}

		Gift.where(created_at: 4.weeks.ago).find_each do |gift|

			mid = gift.merchant_id
			if mhsh[mid].nil?
				{ mid: mid, merchant: g.merchant, val: 0, gifts: [], type: 'Merchant' }
			end
			mhsh[mid][:val] += g.original_value
			mhsh[mid][:gifts] << gift

			 # [{"detail"=>"ItsOnMe digital gifts carry a balance and can be used on multiple visits. Any printed certificate is one-time use only.",
			 # "price"=>"10", "photo"=>"https://res.cloudinary.com/drinkboard/image/upload/v1415464767/srjgwfrtymydnfam1csh.jpg", "ccy"=>"USD",
			 # "price_cents"=>1000, "item_id"=>1382, "item_name"=>"$10 gift voucher", "quantity"=>1}]
			items_hsh = gift.cart_ary

			items_hsh.each do |it_hsh|

				it_hsh = it_hsh.symbolize_keys
				mi = MenuItem.find(it_hsh[:item_id])

				if itemhsh[mi.id].nil?
					{ item_id: mi.id, menu_item: mi, val: 0, gifts: [], type: 'MenuItem' }
				end
				itemhsh[mi.id][:val] += it_hsh[:price_cents] * it_hsh[:quantity]
				itemhsh[mi.id][:gifts] << gift

			end

		end

		# get the current merchant list and the menu item lists
		l1 = List.where(token: 'recent-merchant-monthly')
		l2 = List.where(token: 'recent-mennu-items-monthly')
		# loop thru mhsh & item_hsh and sort by the :val amount

		l1.list_graphs.destroy_all
		l2.list_graphs.destroy_all

		mary = mhsh.sort_by { |k,v| v[:val] }.reverse
		mary.each do |ary|
			hsh = ary[1]
			lg  = ListGraph.new(item_id: hsh[:item_id], item_type: hsh[:type])
			l1 << lg
		end
		l1.save

		ith = items_hsh.sort_by { |k,v| v[:val] }.reverse
		ith.each do |it|
			hsh = ary [1]
			lg  = ListGraph.new(item_id: hsh[:item_id], item_type: hsh[:type])
			l2 << lg
		end
		l2.save


		# delete last run items
		# make a list ordered by the :val amount
		# what to do about old list amounts  ?
	end

end