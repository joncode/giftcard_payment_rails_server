class MoveSalesToPayablesOnGift < ActiveRecord::Migration
  def change

    puts "-------------------------  if Gift.rb total is set to value \n"
    puts " this WILL NOT WORK @!!!!!!!!!!!!!!!!!   comment out Gift.any_instance.#total"

    gs = Gift.unscoped
    gs.each do |gift|
        sale = gift.sale
        if sale
            gift.payable = sale
            user_id = gift.giver_id
            user = User.find(user_id)
            gift.giver = user
            gift.value = gift.total
            gift.save
        end
    end

  end
end
