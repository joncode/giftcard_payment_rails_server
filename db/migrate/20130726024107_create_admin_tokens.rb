class CreateAdminTokens < ActiveRecord::Migration
  def change
    create_table :admin_tokens do |t|
      t.string :token

      t.timestamps
    end

    add_index :admin_tokens, :token
  end
end
