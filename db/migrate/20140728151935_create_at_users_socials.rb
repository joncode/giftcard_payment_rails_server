class CreateAtUsersSocials < ActiveRecord::Migration
  def change
    create_table :at_users_socials do |t|
      t.integer :at_user_id
      t.integer :social_id
      t.timestamps
    end
  end
end
