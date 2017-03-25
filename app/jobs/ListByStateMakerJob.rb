class ListByStateMakerJob

    @queue = :database

	def self.perform
		puts "ListByStateMakerJob START"
		mhsh = {}
		nona = []
		# get all active live merchant in batches
		ms = M.where(active: true, live: true, paused: false).find_each do |m|

			# skip bad zips
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

			# k = state abbreviation
			# value = { country: 'US', type: 'state' , abbr: m.state, name: USA_HSH[m.state], ms: [] }

			# get full state list
			name = "#{v[:country]} #{v[:type].capitalize} - #{v[:name]}"
			l = List.find_or_create_by( name: name, item_type: 'merchant', active: true )
			puts "500 Internal " + l.errors.full_messages unless l.errors.messages.empty?

			name = "Golf - #{v[:country]} #{v[:type].capitalize} - #{v[:name]}"
			l_golf = List.find_or_create_by( name: name, item_type: 'merchant', active: true )
			puts "500 Internal " + l_golf.errors.full_messages unless l_golf.errors.messages.empty?

			name = "Restaurants - #{v[:country]} #{v[:type].capitalize} - #{v[:name]}"
			l_food = List.find_or_create_by( name: name, item_type: 'merchant', active: true )
			puts "500 Internal " + l_food.errors.full_messages unless l_food.errors.messages.empty?

				# remove inactive items from each list
			l.remove_inactive_items
			l_golf.remove_inactive_items
			l_food.remove_inactive_items

			ms = v[:ms]
			ms.sort_by! {|m| m.name }

			ms.each do |m|
					# model prevents duplicates
				l.items << m
				if m.affiliate_id == GOLFNOW_ID
					l_golf.items << m
				else
					l_food.items << m
				end
			end

				# sort lists alphabetically
			l.alphabetize

				# remove lists with 0 merchants
			if l_golf.total_items == 0
				l_golf.toggle! :active
			else
				l_golf.alphabetize
			end

			if l_food.total_items == 0
				l_food.toggle! :active
			else
				l_food.alphabetize
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
		l2 = List.where(token: 'recent-menu-items-monthly')
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