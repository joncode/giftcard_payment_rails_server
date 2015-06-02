class AddZipToCards < ActiveRecord::Migration
  def change
    add_column :cards, :zip, :string
  end
end
