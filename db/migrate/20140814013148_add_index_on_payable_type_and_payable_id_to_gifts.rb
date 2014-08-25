class AddIndexOnPayableTypeAndPayableIdToGifts < ActiveRecord::Migration
  def change
  	add_index :gifts, [:payable_id, :payable_type]
  end
end
