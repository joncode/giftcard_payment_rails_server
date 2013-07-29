class AddImageToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :image, :string
  end
end
