class AddPrimaryToUserSocial < ActiveRecord::Migration
  def change
    add_column :user_socials, :primary, :boolean, default: false
  end
end
