class AddSecureImageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :secure_image, :string
  end
end
