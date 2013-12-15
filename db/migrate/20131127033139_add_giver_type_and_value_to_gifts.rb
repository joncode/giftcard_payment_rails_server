class AddGiverTypeAndValueToGifts < ActiveRecord::Migration
  def up
    add_column :gifts, :giver_type, :string
    add_column :gifts, :value, :string

    gs = Gift.unscoped
    gs.each do |gift|
        gift.giver_type = "User"
        gift.value = gift.total
        unless gift.save
            puts "FAIL --------- FAIL --------- gift ID #{gift.id} ------------- FAIL -------------- FAIL"
        end
    end
  end

  def down
    remove_column :gifts, :giver_type
    remove_column :gifts, :value
  end
end
