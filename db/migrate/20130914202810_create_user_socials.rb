class CreateUserSocials < ActiveRecord::Migration
  def change
    create_table :user_socials do |t|
      t.integer :user_id
      t.string  :type_of
      t.string  :identifier

      t.timestamps
    end
  end
end
