class AddFacebookAuthCheckinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_auth_checkin, :boolean
  end
end
