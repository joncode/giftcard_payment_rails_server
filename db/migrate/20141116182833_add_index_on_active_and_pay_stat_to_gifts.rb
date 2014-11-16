class AddIndexOnActiveAndPayStatToGifts < ActiveRecord::Migration
  def change
  	add_index :gifts, [:active, :pay_stat]
  end
end
