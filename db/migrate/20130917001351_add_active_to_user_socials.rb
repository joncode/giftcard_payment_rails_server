class AddActiveToUserSocials < ActiveRecord::Migration
  def change
    add_column :user_socials, :active, :boolean, default: true
  end
end
