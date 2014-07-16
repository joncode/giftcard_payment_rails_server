class AddNameToSocials < ActiveRecord::Migration
  def change
    add_column :socials, :name, :string
  end
end
