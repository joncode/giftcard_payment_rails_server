class AddGiverTypeAndValueToGifts < ActiveRecord::Migration
  def up
    add_column :gifts, :giver_type, :string
    add_column :gifts, :value, :string
  end

  def down
    remove_column :gifts, :giver_type
    remove_column :gifts, :value
  end
end
