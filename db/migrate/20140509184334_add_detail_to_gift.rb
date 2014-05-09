class AddDetailToGift < ActiveRecord::Migration
  def change
    add_column :gifts, :detail, :text
  end
end
