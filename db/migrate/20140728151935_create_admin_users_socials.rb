class CreateAdminUsersSocials < ActiveRecord::Migration
  def change
    create_table :admin_users_socials do |t|
      t.integer :admin_user_id
      t.integer :social_id
      t.timestamps
    end
  end
end
