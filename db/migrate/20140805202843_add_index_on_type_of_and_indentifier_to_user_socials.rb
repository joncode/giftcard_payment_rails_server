class AddIndexOnTypeOfAndIndentifierToUserSocials < ActiveRecord::Migration
  def change
  	add_index :user_socials, [:type_of,:identifier]
  end
end
