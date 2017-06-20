
# # require OpsCloverApi

# class BrandCardJob

# 	def process args={}
# 		@h = args.stringifyKeys!

# 		@order_id = @h['order_id']
# 		@item_id = @h['item_id']
# 		@max_count = @h['max_count']
# 		@discount_amount = @h['discount_amount']
# 		@discount_name = @h['discount_name']
# 		@count = 0;

# 		clover_api = OpsCloverApi.new  # TODO - add init parms
# 		@line_items = clover_api.get_line_items @order_id, 'line_item_id'
# 		@line_items = @line_items.select { | line_item | line_item['item_id'] == @item_id }

# 		@line_items.each do | line_item |
# 			if line_item.haskey( 'discount')
# 				@count += 1
# 			elsif @count < @max_count
# 				@count += 1
# 				line_item[:amount] = @discount_amount
# 				line_item[:name] = @discount_name
# 				result = clover_api.post_line_item_discount line_item
# 				return result
# 			else
# 				break
# 			end
# 		end

# 		if @count == 0
# 			result = { :status => 0, :data => NOTHING_FOUND }
# 		elsif @count >= @max_count
# 			result = { :status => 0, :data => ALL_DISCOUNTS_TAKEN }
# 		end
# 		return result
# 	end

