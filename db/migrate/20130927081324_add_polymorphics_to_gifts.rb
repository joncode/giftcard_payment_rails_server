class AddPolymorphicsToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :payable_id, :integer
    add_column :gifts, :payable_type, :string
  end
end
