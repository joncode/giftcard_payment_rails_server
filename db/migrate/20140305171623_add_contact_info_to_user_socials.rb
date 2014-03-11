class AddContactInfoToUserSocials < ActiveRecord::Migration
  def change
    add_column :user_socials, :name,        :string
    add_column :user_socials, :birthday,    :date
    add_column :user_socials, :handle,      :string
  end
end
