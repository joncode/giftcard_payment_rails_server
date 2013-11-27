class AddGiverTypeAndValueToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :giver_type, :string
    add_column :gifts, :value, :string
  end
end
