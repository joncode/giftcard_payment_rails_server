class MoveSalesToPayablesOnGift < ActiveRecord::Migration

    def up
        puts "-------------------------  if Gift.rb total is set to value \n"
        puts " this WILL NOT WORK @!!!!!!!!!!!!!!!!!   comment out Gift.any_instance.#total"

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
