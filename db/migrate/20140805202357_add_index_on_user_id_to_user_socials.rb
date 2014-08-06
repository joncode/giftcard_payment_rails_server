class AddIndexOnUserIdToUserSocials < ActiveRecord::Migration
  def change
  	add_index :user_socials, :user_id
  end
end
