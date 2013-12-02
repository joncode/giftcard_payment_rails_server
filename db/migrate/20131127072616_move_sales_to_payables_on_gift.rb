class MoveSalesToPayablesOnGift < ActiveRecord::Migration

    def up
        puts "-------------------------  if Gift.rb total is set to value \n"
        puts " this WILL NOT WORK @!!!!!!!!!!!!!!!!!  in gift.rb ->  comment out  -> def total; blah; end"
        puts " all giver_types must be set to User after this is done"
        puts " all gift.value must equal the shoppingCart total "
        puts " all gifts witha sale must have gift.payable set to Sale"


        gs = Gift.unscoped
        gs.each do |gift|
            user_id    = gift.giver_id
            user       = User.find(user_id)
            gift.giver = user
            gift.value = gift.total
            sale = gift.sale
            if sale
                gift.payable = sale
            end
            gift.save
        end

    end

    def down
        gs = Gift.unscoped
        gs.each do |gift|
            sale = gift.payable
            if sale
                gift.sale = sale
            end
            gift.total = gift.value
            gift.save
        end
    end
end
