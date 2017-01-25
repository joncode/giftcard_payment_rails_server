class ListSpecials

	class << self

		def user_gifts user: , client: , choice: nil, limit: 50, offset: 0

	        scope_choice = ''
	        if choice.present?
		        scope_choice = "scope=#{choice}&"
		        choice = choice.to_sym
	        end

	        gifts = Gift.get_user_scope(user: user, client_partner: client, limit: limit, type: choice)
	        num = Gift.count_user_scope(user: user, client_partner: client, type: choice)

	        _serialized = { owner_type: user.class.to_s, owner_id: user.id, type: "list",
	        	api_url: "#{APIURL}/gifts/list?#{scope_choice}limit=#{limit}&offset=#{offset}",
	            item_type: 'gift', total_items: num, limit: limit, offset: offset,
	            items: gifts.serialize_objs(:web), next: nil, prev: nil }

	        if limit + offset < num
	            _serialized[:next] = "#{APIURL}/gifts/list?#{scope_choice}limit=#{limit}&offset=#{offset + limit}"
	        end
	        if offset != 0
	            prev_offset = offset - limit
	            if prev_offset < 0
	                prev_offset = 0
	            end
	            _serialized[:prev] = "#{APIURL}/gifts/list?#{scope_choice}limit=#{limit}&offset=#{prev_offset}"
	        end

	        _serialized
		end

	end

end