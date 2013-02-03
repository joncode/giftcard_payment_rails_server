class AddTwitterToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :twitter, :string
  end
end
