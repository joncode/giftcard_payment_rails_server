class AddCodeToUserSocials < ActiveRecord::Migration
  def change
    add_column :user_socials, :code, :string
  end
end
