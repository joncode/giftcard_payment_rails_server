class AddTermAndAmountToCards < ActiveRecord::Migration
  def change
    add_column :cards, :term, :string
    add_column :cards, :amount, :integer
  end
end
