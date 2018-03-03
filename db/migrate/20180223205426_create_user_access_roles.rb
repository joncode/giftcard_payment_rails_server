class CreateUserAccessRoles < ActiveRecord::Migration
  def change
    create_table :user_access_roles do |t|
      t.string   :code,    null: false   # Role identifier
      t.string   :label,   null: false   # Displayed to the user
      t.boolean  :active,  null: false,  default: true
    end
  end
end
