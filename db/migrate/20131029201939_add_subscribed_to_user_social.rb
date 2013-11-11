class AddSubscribedToUserSocial < ActiveRecord::Migration
  def change
    add_column :user_socials, :subscribed, :boolean, default: false
  end
end
