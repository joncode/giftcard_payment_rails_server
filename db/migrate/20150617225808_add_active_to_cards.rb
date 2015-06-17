class AddActiveToCards < ActiveRecord::Migration
  def change
    add_column :cards, :active, :boolean, default: true
  	add_index :cards, :active
  end
end
