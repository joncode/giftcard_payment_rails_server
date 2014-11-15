class AddPhotoLToProviders < ActiveRecord::Migration
  def change
  	add_column :providers, :photo_l, :string
  end
end
