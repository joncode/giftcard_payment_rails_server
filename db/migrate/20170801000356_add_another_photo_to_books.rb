class AddAnotherPhotoToBooks < ActiveRecord::Migration
  def change
	add_column :books, :photo5, :string
	add_column :books, :photo5_name, :string
  end
end
