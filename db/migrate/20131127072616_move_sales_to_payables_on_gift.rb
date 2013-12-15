class MoveSalesToPayablesOnGift < ActiveRecord::Migration

    def up
        puts "-------------------------  if Gift.rb total is set to value \n"
        puts " all gifts witha sale must have gift.payable set to Sale"
        puts "gift.sale MUST work here "


        gs = Gift.unscoped
        gs.each do |gift|
            payable = gift.sale
            if payable
                gift.payable = payable
            end
            gift.save
        end

    end

    def down
        # nothing
    end
end
