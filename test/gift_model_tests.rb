class GiftTests
    
    def initialize
        @gift = Gift.new
        test_create_gift_with_gift_items 
    end
    
    def test_create_gift_with_gift_items
        test_amount_of_gifts = 7
        i = 0
    	p = Provider.first
    	menu = Menu.find_all_by_provider_id p.id
    	gift_item_array = []
    	while i < test_amount_of_gifts
    	    menu_hash = make_hash_from_menu_item menu[i]
    	    gift_item = make_gift_item_from_menu_item menu_hash
    	    gift_item_array << gift_item
    	    puts " gift item = #{gift_item.inspect}"
    	    i += 1
    	end
    	@gift.shoppingCart = gift_item_array
    	@gift.gift_items = gift_item_array
    	@gift.add_provider p
    	user1 = User.first
    	user2 = User.next(user1).shift
    	@gift.add_giver user1
    	@gift.add_receiver user2
    	add_total_and_tip @gift
    	if @gift.save
    	    puts "GIFT SAVED YES #{@gift.inspect}"
    	else
    	    puts "GIFT SAVE FAIL #{@gift.errors.messages}"
    	end
    end
    
    def add_total_and_tip gift
        gift.total = 0
        puts "shopping cart = #{gift.shoppingCart}"
        gift.shoppingCart.each do |gift_item|
            amount = gift_item.price.to_i * gift_item.quantity
            gift.total += amount
        end
        gift.tip = gift.total * 0.2
        gift.total = gift.total + gift.tip
        gift.shoppingCart = gift.shoppingCart.to_json
    end
    

    def make_hash_from_menu_item menu_item
        menu_hash = menu_item.serializable_hash
        menu_hash["quantity"] = rand(3) + 1
        return menu_hash
    end 

    def	make_gift_item_from_menu_item menu_item
    	return GiftItem.initFromDictionary menu_item
    end
    
    
end