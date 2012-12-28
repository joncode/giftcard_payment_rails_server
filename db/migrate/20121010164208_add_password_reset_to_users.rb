class AddPasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_token_sent_at, :datetime
    add_column :users, :reset_token, 		 :string
  end
end
